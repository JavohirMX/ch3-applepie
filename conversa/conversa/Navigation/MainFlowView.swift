import SwiftUI

struct MainFlowView: View {
    @Environment(JourneyStore.self) private var journeyStore
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                onContinueJourney: { path.append(.transcription) },
                onNewJourney: { path.append(.uploadTicket(isNewJourney: true)) },
                onOpenSettings: { path.append(.settings) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .settings:
            SettingsView(
                onEditBoardingPass: { path.append(.ticketInformation(mode: .edit)) }
            )
        case .uploadTicket:
            UploadTicketView(
                isNewJourney: true,
                onUploaded: {
                    path.append(.ticketInformation(mode: .newJourney))
                },
                onBack: {
                    if !path.isEmpty {
                        path.removeLast()
                    }
                }
            )
        case .ticketInformation(let mode):
            TicketInformationView(
                mode: mode,
                onConfirm: { handleTicketConfirm(mode: mode) },
                onBack: {
                    if !path.isEmpty {
                        path.removeLast()
                    }
                }
            )
        case .transcription:
            TranscriptionView(onExit: { path.removeLast() })
        }
    }

    private func handleTicketConfirm(mode: TicketEditorMode) {
        switch mode {
        case .edit:
            path.removeLast()
        case .newJourney:
            path = [.transcription]
        case .setupCompletion:
            break
        }
    }
}

#Preview("Main flow") {
    MainFlowView()
        .environment(JourneyStore())
}
