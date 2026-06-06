import SwiftUI

struct TicketInformationView: View {
    let mode: TicketEditorMode
    var onConfirm: () -> Void = {}
    var onBack: (() -> Void)?

    @Environment(JourneyStore.self) private var journeyStore
    @Environment(\.dismiss) private var dismiss

    @State private var passengerName = ""
    @State private var fromAirport = ""
    @State private var toAirport = ""
    @State private var departureDate = Date()
    @State private var flightID = ""
    @State private var departureTime = ""
    @State private var seat = ""
    @State private var gate = ""
    @State private var boardingTime = ""

    private var isEditMode: Bool {
        mode == .edit
    }

    private var confirmTitle: String {
        isEditMode ? "Done" : "Confirm"
    }

    private var confirmForegroundColor: Color {
        isEditMode ? .white : BrandColors.navy
    }

    private var fieldLabelColor: Color {
        isEditMode ? BrandColors.navy : BrandColors.formLabelMuted
    }

    private var fieldLabelFont: Font {
        isEditMode ? Typography.formLabel : Typography.formLabelMuted
    }

    private var usesCapsuleFields: Bool {
        !isEditMode
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SetupHeaderView(
                    title: "Ticket Information",
                    subtitle: "Check your ticket information and edit it if there is wrong informations",
                    subtitleColor: BrandColors.setupSubtitle
                )

                TicketStubCard(
                    title: "Your Ticket",
                    titleAlignment: .center,
                    showsDashedDivider: true,
                    shape: TicketStubShape(notchRadius: 5, notchSpacing: 12)
                ) {
                    VStack(spacing: 16) {
                        ticketField(label: "Name", text: $passengerName)

                        HStack(alignment: .top, spacing: 12) {
                            ticketField(label: "From", text: $fromAirport)
                            ticketField(label: "To", text: $toAirport)
                        }

                        HStack(alignment: .top, spacing: 12) {
                            dateField
                            ticketField(label: "Flight ID", text: $flightID)
                        }

                        HStack(alignment: .top, spacing: 12) {
                            ticketField(label: "Time", text: $departureTime)
                            ticketField(label: "Boarding Time", text: $boardingTime)
                        }

                        HStack(alignment: .top, spacing: 12) {
                            ticketField(label: "Seat", text: $seat)
                            ticketField(label: "Gate", text: $gate)
                        }

                        SetupPrimaryButton(
                            title: confirmTitle,
                            foregroundColor: confirmForegroundColor,
                            action: confirm
                        )
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(BrandColors.setupPageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SetupBackButton(action: handleBack)
            }
        }
        .onAppear(perform: loadTicket)
    }

    private var dateField: some View {
        SetupFormField(
            label: "Date",
            labelColor: fieldLabelColor,
            labelFont: fieldLabelFont
        ) {
            DatePicker(
                "",
                selection: $departureDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .foregroundStyle(BrandColors.navy)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if usesCapsuleFields {
                    Capsule().fill(BrandColors.fieldBackground)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BrandColors.fieldBackground)
                }
            }
        }
    }

    private func ticketField(label: String, text: Binding<String>) -> some View {
        SetupFormField(
            label: label,
            labelColor: fieldLabelColor,
            labelFont: fieldLabelFont
        ) {
            TextField("", text: text)
                .foregroundStyle(BrandColors.navy)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    if usesCapsuleFields {
                        Capsule().fill(BrandColors.fieldBackground)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(BrandColors.fieldBackground)
                    }
                }
        }
    }

    private func loadTicket() {
        let source = journeyStore.activeTicket ?? TicketInfo.empty
        passengerName = source.passengerName
        fromAirport = source.fromAirport
        toAirport = source.toAirport
        departureDate = source.departureDate
        flightID = source.flightID
        departureTime = source.departureTime
        seat = source.seat
        gate = source.gate
        boardingTime = source.boardingTime
    }

    private func handleBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func confirm() {
        let ticket = TicketInfo(
            passengerName: passengerName,
            fromAirport: fromAirport,
            toAirport: toAirport,
            departureDate: departureDate,
            flightID: flightID,
            departureTime: departureTime,
            seat: seat,
            gate: gate,
            boardingTime: boardingTime
        )
        journeyStore.activateJourney(with: ticket)
        if mode == .newJourney {
            journeyStore.beginNewJourneySession()
        }
        onConfirm()
    }
}

#Preview("Ticket Information — Setup") {
    NavigationStack {
        TicketInformationView(mode: .setupCompletion)
    }
    .environment(JourneyStore())
}

#Preview("Ticket Information — Settings Edit") {
    NavigationStack {
        TicketInformationView(mode: .edit)
    }
    .environment({
        let store = JourneyStore()
        store.activeTicket = TicketInfo.mockSample
        return store
    }())
}
