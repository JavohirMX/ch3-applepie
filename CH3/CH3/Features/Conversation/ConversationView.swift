import SwiftUI

struct ConversationView: View {
    let chat: RecentChat

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var micIsActive = false
    @State private var lastSpokenText: String?

    private let bottomScrollID = "chatBottom"

    private var theme: CategoryTheme {
        CategoryTheme.theme(for: chat.category)
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
                                if messages.isEmpty {
                                    emptyState
                                } else {
                                    ForEach(groupedMessages) { item in
                                        ChatMessageRow(
                                            item: item,
                                            theme: theme,
                                            maxBubbleWidth: maxBubbleWidth,
                                            onSpeak: speakMessage
                                        )
                                        .id(item.id)
                                        .transition(bubbleTransition(for: item.message))
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
                    }

                    bottomComposer
                }
            }
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: lastSpokenText)
        .onAppear {
            if chat.isNewConversation {
                messages = []
            } else {
                messages = AppMockData.transcriptMessages
            }
        }
    }

    private func bubbleTransition(for message: ChatMessage) -> AnyTransition {
        switch message.sender {
        case .user:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity
            )
        case .other:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .opacity
            )
        case .system:
            return .opacity
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        guard !messages.isEmpty else { return }
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(bottomScrollID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(bottomScrollID, anchor: .bottom)
        }
    }

    private func appendMessage(_ message: ChatMessage) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            messages.append(message)
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        appendMessage(.user(trimmed))
        inputText = ""
    }

    private func speakMessage(_ text: String) {
        lastSpokenText = text
    }

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

    private var bottomComposer: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primary)
                Text("Suggestions")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primary)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 8) {
                ForEach(AppMockData.transcriptSuggestions) { suggestion in
                    SuggestionChipView(text: suggestion.text, theme: theme) {
                        appendMessage(.user(suggestion.text))
                    }
                }
            }

            MessageGlassInputBar(text: $inputText, onSend: sendMessage, theme: theme)

            HStack {
                Spacer()
                Button {
                    micIsActive.toggle()
                    if micIsActive {
                        appendMessage(.system("Listening..."))
                    } else if messages.last?.sender == .system {
                        withAnimation {
                            _ = messages.popLast()
                        }
                    }
                } label: {
                    Image(systemName: micIsActive ? "stop.fill" : "mic.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 72)
                        .glassEffect(.regular.tint(theme.primary).interactive(), in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(micIsActive ? "Stop live transcribe" : "Start live transcribe")
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
