import SwiftUI

struct SetupFlowView: View {
    var onComplete: () -> Void

    @Environment(JourneyStore.self) private var journeyStore
    @State private var path: [SetupRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            PersonalPreferencesView(
                mode: .firstRun,
                onContinue: { path.append(.uploadTicket) },
                onSkip: { path.append(.uploadTicket) }
            )
            .navigationDestination(for: SetupRoute.self) { route in
                switch route {
                case .uploadTicket:
                    UploadTicketView(
                        onUploaded: {
                            journeyStore.activeTicket = TicketInfo.mockSample
                            path.append(.ticketInformation)
                        }
                    )
                case .ticketInformation:
                    TicketInformationView(
                        mode: .setupCompletion,
                        onConfirm: onComplete
                    )
                }
            }
        }
    }
}
