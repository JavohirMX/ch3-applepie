import SwiftUI
import Speech

struct ConversationView: View {
    let chat: RecentChat

    // MARK: - Message state

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isSending = false
    @State private var sendError: String?
    @State private var isLoadingHistory = false
    @State private var historyError: String?

    // MARK: - Speech

    @State private var speechService = SpeechService.shared
    @State private var micPermissionDenied = false
    @State private var lastSpokenText: String?

    // MARK: - Suggestions

    @State private var suggestions: [PhraseSuggestion] = []
    @State private var isLoadingSuggestions = false

    private let bottomScrollID = "chatBottom"

    private var theme: CategoryTheme {
        CategoryTheme.theme(for: chat.category)
    }

    private var speechLocale: Locale {
        LocaleMapper.speechLocale(for: chat.countryCode)
    }

    private var groupedMessages: [GroupedChatMessage] {
        ChatMessageLayout.grouped(messages)
    }

    var body: some View {
        GeometryReader { geometry in
            let maxBubbleWidth = geometry.size.width * 0.78

            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                if isLoadingHistory {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .padding(.vertical, 60)
                                        Spacer()
                                    }
                                } else if let error = historyError {
                                    historyErrorState(error)
                                } else if messages.isEmpty {
                                    emptyState
                                } else {
                                    ForEach(groupedMessages) { item in
                                        ChatMessageRow(
                                            item: item,
                                            theme: theme,
                                            maxBubbleWidth: maxBubbleWidth,
                                            onSpeak: { text in
                                                speechService.speak(text, locale: speechLocale)
                                            }
                                        )
                                        .id(item.id)
                                    }
                                }

                                Color.clear
                                    .frame(height: 1)
                                    .id(bottomScrollID)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: messages.count) { _, _ in
                            scrollToBottom(proxy: proxy)
                        }
                        .onChange(of: speechService.liveTranscript) { _, _ in
                            scrollToBottom(proxy: proxy)
                        }
                    }

                    // Live transcription banner (appears above composer while listening)
                    if speechService.isListening {
                        liveTranscriptBanner
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    bottomComposer
                }
                .animation(.easeInOut(duration: 0.25), value: speechService.isListening)
            }
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: lastSpokenText)
        .task {
            await loadMessageHistory()
            await loadSuggestions()
        }
    }

    // MARK: - Live transcription banner

    private var liveTranscriptBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            // Pulsing red dot
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
                .phaseAnimator([false, true]) { view, phase in
                    view.opacity(phase ? 0.3 : 1.0)
                } animation: { _ in
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Listening")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.primary)
                        .textCase(.uppercase)

                    if let language = speechService.detectedLanguage {
                        Text(language)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.primary.opacity(0.7))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.primary.opacity(0.1), in: Capsule())
                    }
                }

                Text(speechService.liveTranscript.isEmpty
                     ? "Speak now — language will be detected automatically"
                     : speechService.liveTranscript)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.primary.opacity(0.6))
                .frame(height: 2)
        }
    }

    // MARK: - Data loading

    private func loadMessageHistory() async {
        guard !chat.isNewConversation else { return }

        isLoadingHistory = true
        historyError = nil

        do {
            let responses = try await MessageService.shared.getMessageHistory(chatId: chat.id.uuidString)
            messages = responses.map { ChatMessage(from: $0) }
        } catch {
            historyError = error.localizedDescription
        }

        isLoadingHistory = false
    }

    private func loadSuggestions() async {
        isLoadingSuggestions = true

        do {
            let phrases = try await FormService.shared.getSuggestions(chatId: chat.id.uuidString)
            suggestions = phrases.map { PhraseSuggestion(text: $0) }
        } catch {
            print("[ConversationView] Suggestions load failed: \(error.localizedDescription)")
        }

        isLoadingSuggestions = false
    }

    // MARK: - Sending (typed messages)

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        let userText = trimmed
        inputText = ""
        sendError = nil

        let userMessage = ChatMessage.user(userText)
        appendMessage(userMessage)

        Task {
            await sendToBackend(userText: userText)
        }
    }

    private func sendToBackend(userText: String) async {
        isSending = true

        do {
            let response = try await MessageService.shared.sendMessage(
                chatId: chat.id.uuidString,
                text: userText
            )
            let aiMessage = ChatMessage(from: response.aiMessage)
            appendMessage(aiMessage)
            await loadSuggestions()
        } catch {
            sendError = error.localizedDescription
        }

        isSending = false
    }

    // MARK: - STT: Mic button

    private func handleMicTap() {
        if speechService.isListening {
            stopMicAndProcess()
        } else {
            startMic()
        }
    }

    private func startMic() {
        // Check permission first
        if speechService.authorizationStatus == .notDetermined {
            Task {
                let status = await speechService.requestAuthorization()
                if status == .authorized {
                    doStartListening()
                } else {
                    micPermissionDenied = true
                }
            }
            return
        }

        if speechService.authorizationStatus != .authorized {
            micPermissionDenied = true
            return
        }

        doStartListening()
    }

    private func doStartListening() {
        do {
            // Auto-detect spoken language (no locale lock)
            try speechService.startListening()
        } catch {
            sendError = error.localizedDescription
        }
    }

    private func stopMicAndProcess() {
        let transcript = speechService.stopListening()

        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Append transcribed message
        let transcribedMessage = ChatMessage.other(
            transcript,
            isTranscribedLive: true
        )
        appendMessage(transcribedMessage)

        // Auto-send transcript to AI for a reply
        Task {
            await sendToBackend(userText: transcript)
        }
    }

    // MARK: - TTS speak (triggered by speaker icon on messages)

    // Handled inline via speechService.speak(text, locale: speechLocale)

    // MARK: - Message helpers

    private func appendMessage(_ message: ChatMessage) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            messages.append(message)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(bottomScrollID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(bottomScrollID, anchor: .bottom)
        }
    }

    // MARK: - Empty & error states

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundStyle(theme.primary.opacity(0.5))
            Text("You can now start the conversation")
                .font(AppTypography.body)
                .foregroundStyle(theme.primary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    private func historyErrorState(_ error: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.textSecondary)
            Text(error)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await loadMessageHistory() }
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.primary)
        }
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bottom composer

    private var bottomComposer: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Suggestions header
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primary)
                Text("Suggestions")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primary)
            }
            .padding(.horizontal, 4)

            // Suggestion chips
            if isLoadingSuggestions && suggestions.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Spacer()
                }
                .padding(.vertical, 4)
            } else if !suggestions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(suggestions) { suggestion in
                        SuggestionChipView(text: suggestion.text, theme: theme) {
                            inputText = suggestion.text
                        }
                    }
                }
            }

            // Error
            if let error = sendError {
                Text(error)
                    .font(AppTypography.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 4)
            }

            // Permission denied alert
            if micPermissionDenied {
                HStack(spacing: 8) {
                    Image(systemName: "mic.slash.fill")
                        .foregroundStyle(.red)
                    Text("Microphone access denied. Enable in Settings.")
                        .font(AppTypography.caption)
                        .foregroundStyle(.red)
                    Spacer()
                    Button("Dismiss") { micPermissionDenied = false }
                        .font(AppTypography.caption.weight(.semibold))
                }
                .padding(.horizontal, 4)
            }

            // Text input bar
            MessageGlassInputBar(text: $inputText, onSend: sendMessage, theme: theme)
                .disabled(isSending)

            // Mic button
            HStack {
                Spacer()
                Button(action: handleMicTap) {
                    Image(systemName: speechService.isListening ? "stop.fill" : "mic.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .glassEffect(.regular.tint(theme.primary).interactive(), in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(speechService.isListening ? "Stop recording" : "Start recording")
                .sensoryFeedback(.impact(weight: .medium), trigger: speechService.isListening)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -2)
    }
}
