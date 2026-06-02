import AVFoundation
import NaturalLanguage
import Speech
import Observation

/// Manages speech recognition (STT) and text-to-speech (TTS).
///
/// Uses Apple's native frameworks:
/// - `SFSpeechRecognizer` for live speech-to-text with language auto-detection
/// - `AVSpeechSynthesizer` for text-to-speech playback
///
/// Both work on-device with no API keys or network calls required.
@Observable
final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()

    // MARK: - Permission

    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    // MARK: - STT state

    /// Whether the microphone is actively listening.
    var isListening = false

    /// Real-time partial transcript as the person speaks.
    var liveTranscript = ""

    /// The detected spoken language (e.g., "Japanese", "French"), updated live.
    var detectedLanguage: String?

    /// Error during speech recognition (e.g., no microphone access).
    var recognitionError: String?

    // MARK: - TTS state

    /// Whether text is currently being spoken.
    var isSpeaking = false

    // MARK: - Private STT

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let languageRecognizer = NLLanguageRecognizer()

    // MARK: - Private TTS

    private let speechSynthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }

    // MARK: - Permission

    /// Request speech recognition authorization.
    /// Must be called before `startListening()`.
    @MainActor
    func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
        return status
    }

    // MARK: - STT: Start listening (auto-detect language)

    /// Start live speech recognition with automatic language detection.
    ///
    /// Uses the default recognizer (no locale constraint) with on-device processing,
    /// which detects the spoken language automatically across all supported languages.
    ///
    /// - Throws: If audio session cannot be configured or recognizer is unavailable.
    func startListening() throws {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable("auto-detect")
        }

        // Cancel any previous task
        stopListening(shouldFinalize: false)

        recognitionError = nil
        liveTranscript = ""
        detectedLanguage = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechError.recognitionRequestFailed
        }
        recognitionRequest.shouldReportPartialResults = true

        // Enable on-device recognition for better language detection
        if recognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
        }

        // Install tap on the input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isListening = true

        // Start recognition
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let transcript = result.bestTranscription.formattedString
                Task { @MainActor in
                    self.liveTranscript = transcript
                    // Detect language once we have enough text (>10 chars)
                    if transcript.count > 10 {
                        self.updateDetectedLanguage(from: transcript)
                    }
                }
            }

            if let error {
                Task { @MainActor in
                    self.recognitionError = error.localizedDescription
                }
                self.stopListening(shouldFinalize: false)
            }
        }
    }

    /// Start live speech recognition locked to a specific locale.
    ///
    /// Use this when you know the expected language and want maximum accuracy.
    /// For multi-language environments, call `startListening()` (no parameters) instead.
    ///
    /// - Parameter locale: The locale for the expected spoken language (e.g., `Locale(identifier: "ja-JP")`).
    /// - Throws: If audio session cannot be configured or recognizer is unavailable.
    func startListening(locale: Locale) throws {
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable(locale.identifier)
        }

        // Cancel any previous task
        stopListening(shouldFinalize: false)

        recognitionError = nil
        liveTranscript = ""
        // Set detected language from the locale upfront
        detectedLanguage = Locale.current.localizedString(forIdentifier: locale.identifier) ?? locale.identifier

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechError.recognitionRequestFailed
        }
        recognitionRequest.shouldReportPartialResults = true

        // Install tap on the input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isListening = true

        // Start recognition
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let transcript = result.bestTranscription.formattedString
                Task { @MainActor in
                    self.liveTranscript = transcript
                }
            }

            if let error {
                Task { @MainActor in
                    self.recognitionError = error.localizedDescription
                }
                self.stopListening(shouldFinalize: false)
            }
        }
    }

    /// Detect the spoken language from transcribed text using NLLanguageRecognizer.
    private func updateDetectedLanguage(from text: String) {
        // Only update once we have enough text for reliable detection
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count > 10 else { return }

        languageRecognizer.processString(cleaned)

        guard let language = languageRecognizer.dominantLanguage,
              let languageName = Locale.current.localizedString(forIdentifier: language.rawValue) else {
            return
        }

        // Only update if it changed (avoids unnecessary UI updates)
        if detectedLanguage != languageName {
            detectedLanguage = languageName
        }
    }

    // MARK: - STT: Stop listening

    /// Stop speech recognition and return the final transcript.
    ///
    /// - Returns: The final transcribed text.
    @discardableResult
    func stopListening() -> String {
        stopListening(shouldFinalize: true)
        return liveTranscript
    }

    private func stopListening(shouldFinalize: Bool) {
        if shouldFinalize {
            recognitionTask?.finish()
        } else {
            recognitionTask?.cancel()
        }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        isListening = false
    }

    // MARK: - TTS: Speak

    /// Speak the given text aloud using the specified locale's voice.
    ///
    /// - Parameters:
    ///   - text: The text to speak.
    ///   - locale: The locale determining the voice/language to use.
    func speak(_ text: String, locale: Locale) {
        // Stop any current speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)

        // Select the best voice for this locale
        if let voice = AVSpeechSynthesisVoice(language: locale.identifier) {
            utterance.voice = voice
        }

        // Slightly slower rate for clarity
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85

        // Slightly lower pitch for natural sound
        utterance.pitchMultiplier = 0.95

        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }

    /// Stop any ongoing speech synthesis.
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}

// MARK: - Errors

enum SpeechError: LocalizedError {
    case recognizerUnavailable(String)
    case recognitionRequestFailed

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable(let locale):
            return "Speech recognition is not available for \(locale)."
        case .recognitionRequestFailed:
            return "Failed to start speech recognition."
        }
    }
}
