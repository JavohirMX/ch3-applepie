import SwiftUI

struct TicketInformationView: View {
    let mode: TicketEditorMode
    var onConfirm: () -> Void = {}

    @Environment(JourneyStore.self) private var journeyStore

    @State private var passengerName = ""
    @State private var fromAirport = ""
    @State private var toAirport = ""
    @State private var departureDate = Date()
    @State private var flightID = ""
    @State private var departureTime = ""
    @State private var seat = ""
    @State private var gate = ""
    @State private var boardingTime = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if mode != .edit {
                    SetupHeaderView(
                        title: "Ticket Information",
                        subtitle: "Check your ticket information and edit it if there is wrong informations"
                    )
                }

                TicketStubCard(title: "Your Ticket Information") {
                    VStack(spacing: 16) {
                        ticketField(label: "Name", text: $passengerName)
                        HStack(spacing: 12) {
                            ticketField(label: "From", text: $fromAirport)
                            ticketField(label: "To", text: $toAirport)
                        }
                        HStack(spacing: 12) {
                            dateField
                            ticketField(label: "Flight ID", text: $flightID)
                            ticketField(label: "Time", text: $departureTime)
                        }
                        HStack(spacing: 12) {
                            ticketField(label: "Seat", text: $seat)
                            ticketField(label: "Gate", text: $gate)
                            ticketField(label: "Boarding Time", text: $boardingTime)
                        }
                    }
                }

                SetupPrimaryButton(title: "Confirm", action: confirm)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .navigationTitle(mode == .edit ? "Edit Ticket" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadTicket)
    }

    private var dateField: some View {
        SetupFormField(label: "Date") {
            DatePicker(
                "",
                selection: $departureDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BrandColors.fieldBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func ticketField(label: String, text: Binding<String>) -> some View {
        SetupFormField(label: label) {
            TextField("", text: text)
                .foregroundStyle(BrandColors.navy)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(BrandColors.fieldBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func loadTicket() {
        let source = journeyStore.activeTicket ?? TicketInfo.mockSample
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
