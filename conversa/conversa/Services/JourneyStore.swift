import Foundation
import Observation

@MainActor
@Observable
final class JourneyStore {
    var userPreferences: UserPreferences {
        didSet { persistPreferences() }
    }

    var activeTicket: TicketInfo? {
        didSet { persistTicket() }
    }

    var uploadedTicketImageData: Data? {
        didSet { persistImage() }
    }

    var savedTranscript: String {
        didSet { persistSession() }
    }

    var savedDraftText: String {
        didSet { persistSession() }
    }

    var hasActiveJourney: Bool {
        didSet { UserDefaults.standard.set(hasActiveJourney, forKey: Keys.hasActiveJourney) }
    }

    private enum Keys {
        static let preferences = "savedUserPreferences"
        static let ticket = "savedTicketInfo"
        static let image = "uploadedTicketImageData"
        static let transcript = "savedTranscript"
        static let draft = "savedDraftText"
        static let hasActiveJourney = "hasActiveJourney"
    }

    init() {
        userPreferences = Self.loadPreferences()
        activeTicket = Self.loadTicket()
        uploadedTicketImageData = UserDefaults.standard.data(forKey: Keys.image)
        savedTranscript = UserDefaults.standard.string(forKey: Keys.transcript) ?? ""
        savedDraftText = UserDefaults.standard.string(forKey: Keys.draft) ?? ""
        hasActiveJourney = UserDefaults.standard.bool(forKey: Keys.hasActiveJourney)
    }

    func activateJourney(with ticket: TicketInfo) {
        activeTicket = ticket
        hasActiveJourney = true
    }

    func beginNewJourneySession() {
        savedTranscript = ""
        savedDraftText = ""
    }

    func persistCurrentSession(transcript: String, draftText: String) {
        savedTranscript = transcript
        savedDraftText = draftText
    }

    // MARK: - Persistence

    private func persistPreferences() {
        guard let data = try? JSONEncoder().encode(userPreferences) else { return }
        UserDefaults.standard.set(data, forKey: Keys.preferences)
    }

    private func persistTicket() {
        guard let ticket = activeTicket, let data = try? JSONEncoder().encode(ticket) else {
            UserDefaults.standard.removeObject(forKey: Keys.ticket)
            return
        }
        UserDefaults.standard.set(data, forKey: Keys.ticket)
    }

    private func persistImage() {
        if let uploadedTicketImageData {
            UserDefaults.standard.set(uploadedTicketImageData, forKey: Keys.image)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.image)
        }
    }

    private func persistSession() {
        UserDefaults.standard.set(savedTranscript, forKey: Keys.transcript)
        UserDefaults.standard.set(savedDraftText, forKey: Keys.draft)
    }

    private static func loadPreferences() -> UserPreferences {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.preferences),
            let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data)
        else {
            return .empty
        }
        return prefs
    }

    private static func loadTicket() -> TicketInfo? {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.ticket),
            let ticket = try? JSONDecoder().decode(TicketInfo.self, from: data)
        else {
            return nil
        }
        return ticket
    }
}
