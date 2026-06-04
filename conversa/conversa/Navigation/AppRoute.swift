import Foundation

enum TicketEditorMode: Hashable {
    case setupCompletion
    case newJourney
    case edit
}

enum PreferencesEditorMode: Hashable {
    case firstRun
    case settings
}

enum AppRoute: Hashable {
    case settings
    case uploadTicket(isNewJourney: Bool)
    case ticketInformation(mode: TicketEditorMode)
    case personalPreferences(mode: PreferencesEditorMode)
    case transcription
}

enum SetupRoute: Hashable {
    case uploadTicket
    case ticketInformation
}
