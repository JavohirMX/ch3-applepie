import SwiftUI

struct SetupFlowView: View {
    var onComplete: () -> Void

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
                            path.append(.ticketInformation)
                        },
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                case .ticketInformation:
                    TicketInformationView(
                        mode: .setupCompletion,
                        onConfirm: onComplete,
                        onBack: {
                            if !path.isEmpty {
                                path.removeLast()
                            }
                        }
                    )
                }
            }
        }
    }
}
