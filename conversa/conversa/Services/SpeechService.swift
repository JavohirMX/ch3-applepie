import AVFoundation
import NaturalLanguage
import Observation
import Speech

/// Manages speech recognition (STT) and text-to-speech (TTS).
@MainActor
@Observable
final class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()

    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    var isListening = false
    var liveTranscript = ""
    var detectedLanguage: String?
    var recognitionError: String?
    var isSpeaking = false

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let languageRecognizer = NLLanguageRecognizer()
    private let speechSynthesizer = AVSpeechSynthesizer()

    private var committedTranscript = ""
    private var currentPartial = ""
    private var isUserStopping = false

    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }

    func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
        return status
    }

    func startListening() throws {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable("auto-detect")
        }

        stopListening(shouldFinalize: false)

        isUserStopping = false
        recognitionError = nil
        committedTranscript = ""
        currentPartial = ""
        liveTranscript = ""
        detectedLanguage = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else {
            throw SpeechError.recognitionRequestFailed
        }
        recognitionRequest.shouldReportPartialResults = true

        if recognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isListening = true

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            if let result {
                Task { @MainActor in
                    self.processRecognitionResult(result)
                }
            }

            if let error {
                Task { @MainActor in
                    self.handleRecognitionError(error)
                }
            }
        }
    }

    @discardableResult
    func stopListening() -> String {
        isUserStopping = true
        recognitionError = nil
        commitOpenPartial()
        stopListening(shouldFinalize: true)
        return liveTranscript
    }

    private func handleRecognitionError(_ error: Error) {
        if isUserStopping {
            isUserStopping = false
            return
        }

        if Self.shouldIgnoreSpeechError(error) {
            return
        }

        recognitionError = error.localizedDescription
        stopListening(shouldFinalize: false)
    }

    private static func shouldIgnoreSpeechError(_ error: Error) -> Bool {
        let nsError = error as NSError

        if nsError.domain == "kAFAssistantErrorDomain", nsError.code == 203 {
            return true
        }

        if nsError.code == 216 || nsError.code == 1110 || nsError.code == 1700 {
            return true
        }

        let message = error.localizedDescription.lowercased()
        if message.contains("cancel")
            || message.contains("no speech")
            || message.contains("no audio")
            || message.contains("retry") {
            return true
        }

        return false
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

    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        let segment = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)

        if result.isFinal {
            appendCommittedIfNew(segment)
            updateDetectedLanguage(from: liveTranscript)
            return
        }

        guard !segment.isEmpty else {
            updateLiveTranscriptDisplay()
            return
        }

        let previousPartial = currentPartial.trimmingCharacters(in: .whitespacesAndNewlines)
        if !previousPartial.isEmpty, !segment.hasPrefix(previousPartial), !previousPartial.hasPrefix(segment) {
            appendCommittedIfNew(previousPartial)
        }

        currentPartial = segment
        updateLiveTranscriptDisplay()
        updateDetectedLanguage(from: liveTranscript)
    }

    /// Merges committed text with a partial hypothesis. Partials from `SFSpeechRecognizer` are
    /// cumulative for the current utterance, so they must not be concatenated blindly.
    static func mergeTranscript(committed: String, partial: String) -> String {
        let committedNormalized = normalizeTranscript(committed)
        let partialNormalized = normalizeTranscript(partial)

        if partialNormalized.isEmpty {
            return committedNormalized
        }
        if committedNormalized.isEmpty {
            return partialNormalized
        }
        if partialNormalized.hasPrefix(committedNormalized) {
            return partialNormalized
        }
        if committedNormalized.hasPrefix(partialNormalized) {
            return committedNormalized
        }
        return committedNormalized + " " + partialNormalized
    }

    static func normalizeTranscript(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func appendCommittedIfNew(_ segment: String) {
        let trimmed = Self.normalizeTranscript(segment)
        guard !trimmed.isEmpty else { return }

        let committed = Self.normalizeTranscript(committedTranscript)

        if committed.isEmpty {
            committedTranscript = trimmed
        } else if trimmed == committed {
            // Already represented.
        } else if trimmed.hasPrefix(committed) {
            committedTranscript = trimmed
        } else if committed.hasPrefix(trimmed) {
            // Stale or shorter segment; keep existing committed text.
        } else {
            committedTranscript = committed + " " + trimmed
        }

        currentPartial = ""
        updateLiveTranscriptDisplay()
    }

    private func commitOpenPartial() {
        let trimmed = Self.normalizeTranscript(currentPartial)
        guard !trimmed.isEmpty else { return }
        appendCommittedIfNew(trimmed)
    }

    private func updateLiveTranscriptDisplay() {
        liveTranscript = Self.mergeTranscript(
            committed: committedTranscript,
            partial: currentPartial
        )
    }

    private func updateDetectedLanguage(from text: String) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count > 10 else { return }

        languageRecognizer.processString(cleaned)

        guard let language = languageRecognizer.dominantLanguage,
              let languageName = Locale.current.localizedString(forIdentifier: language.rawValue) else {
            return
        }

        if detectedLanguage != languageName {
            detectedLanguage = languageName
        }
    }

    func speak(_ text: String, locale: Locale = .current) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        if let voice = AVSpeechSynthesisVoice(language: locale.identifier) {
            utterance.voice = voice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        utterance.pitchMultiplier = 0.95

        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}

enum SpeechError: LocalizedError {
    case recognizerUnavailable(String)
    case recognitionRequestFailed

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable(let locale):
            "Speech recognition is not available for \(locale)."
        case .recognitionRequestFailed:
            "Failed to start speech recognition."
        }
    }
}
