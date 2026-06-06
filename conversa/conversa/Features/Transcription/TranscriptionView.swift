import Speech
import SwiftUI

struct TranscriptionView: View {
    @Environment(JourneyStore.self) private var journeyStore
    var onExit: () -> Void = {}

    @State private var speechService = SpeechService.shared
    @State private var sheetDetent: PresentationDetent = .fraction(0.5)
    @State private var savedTranscript = ""
    @State private var draftText = ""
    @State private var showPermissionAlert = false
    @State private var transcriptionError: String?
    @State private var isTextSheetPresented = true
    @State private var isExiting = false

    private var isSheetCollapsed: Bool {
        sheetDetent == .fraction(0.1)
    }

    private var isSheetFullyExpanded: Bool {
        sheetDetent == .large
    }

    private var isMicIdle: Bool {
        !speechService.isListening
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        TranscriptionBackButton(action: exitTranscription)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    upperContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 24)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Keyboard.dismiss()
                        }

                    MicControlButton(
                        isListening: speechService.isListening,
                        isProminent: sheetDetent == .fraction(0.5) && isMicIdle,
                        showsBreathing: isMicIdle && (sheetDetent == .fraction(0.5) || isSheetCollapsed),
                        action: handleMicTap
                    )
                        .padding(.bottom, 24)
                }
                .padding(.bottom, sheetBottomInset(for: geometry.size.height))
            }
        }
        .sheet(isPresented: $isTextSheetPresented) {
            TextSheet(draftText: $draftText, selectedDetent: $sheetDetent)
                .presentationDetents(
                    [.fraction(0.1), .fraction(0.5), .large],
                    selection: $sheetDetent
                )
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable speech recognition and microphone access in Settings to use live transcription.")
        }
        .alert(
            "Transcription Error",
            isPresented: Binding(
                get: { transcriptionError != nil },
                set: { if !$0 { transcriptionError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { transcriptionError = nil }
        } message: {
            Text(transcriptionError ?? "")
        }
        .animation(.easeInOut(duration: 0.25), value: sheetDetent)
        .onChange(of: speechService.recognitionError) { _, error in
            guard let error else { return }
            transcriptionError = error
        }
        .onAppear {
            isTextSheetPresented = true
            isExiting = false
            savedTranscript = journeyStore.savedTranscript
            draftText = journeyStore.savedDraftText
        }
        .onDisappear {
            if !isExiting {
                persistSession()
            }
        }
    }

    @ViewBuilder
    private var upperContent: some View {
        if speechService.isListening {
            LiveTranscriptArea(liveTranscript: speechService.liveTranscript)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else if !savedTranscript.isEmpty {
            TranscriptDisplayView(text: savedTranscript)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else if isSheetCollapsed {
            TranscriptionPlaceholderView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else if isSheetFullyExpanded {
            Spacer(minLength: 0)
        } else {
            VStack {
                Text("Start Listening")
                    .font(Typography.listeningTitle)
                    .foregroundStyle(BrandColors.navy)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding(.top, 8)
        }
    }

    private func sheetBottomInset(for screenHeight: CGFloat) -> CGFloat {
        if sheetDetent == .fraction(0.1) {
            return screenHeight * 0.12
        }
        if sheetDetent == .large {
            return screenHeight * 0.88
        }
        return screenHeight * 0.52
    }

    private func exitTranscription() {
        guard !isExiting else { return }

        if speechService.isListening {
            savedTranscript = speechService.stopListening()
        }
        persistSession()
        isExiting = true
        isTextSheetPresented = false

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(320))
            guard isExiting else { return }
            onExit()
            isExiting = false
        }
    }

    private func persistSession() {
        journeyStore.persistCurrentSession(transcript: savedTranscript, draftText: draftText)
    }

    private func handleMicTap() {
        if speechService.isListening {
            savedTranscript = speechService.stopListening()
            transcriptionError = nil
            persistSession()
            return
        }

        if speechService.authorizationStatus == .notDetermined {
            Task {
                let status = await speechService.requestAuthorization()
                if status == .authorized {
                    startListening()
                } else {
                    showPermissionAlert = true
                }
            }
            return
        }

        guard speechService.authorizationStatus == .authorized else {
            showPermissionAlert = true
            return
        }

        startListening()
    }

    private func startListening() {
        savedTranscript = ""
        transcriptionError = nil

        if sheetDetent == .fraction(0.5) {
            sheetDetent = .fraction(0.1)
        }

        do {
            try speechService.startListening()
        } catch {
            transcriptionError = error.localizedDescription
        }
    }
}

#Preview("Start Listening") {
    TranscriptionView()
        .environment(JourneyStore())
}

#Preview("Placeholder copy") {
    TranscriptionPlaceholderView()
        .padding(.horizontal, 24)
        .frame(width: 390, height: 700, alignment: .topLeading)
        .background(Color.white)
}

#Preview("Listening placeholder") {
    LiveTranscriptArea(liveTranscript: "")
        .frame(height: 200)
        .padding()
        .background(Color.white)
}
