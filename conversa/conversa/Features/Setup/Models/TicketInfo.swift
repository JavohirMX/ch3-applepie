import Foundation

struct TicketInfo: Codable, Equatable {
    var passengerName: String
    var fromAirport: String
    var toAirport: String
    var departureDate: Date
    var flightID: String
    var departureTime: String
    var seat: String
    var gate: String
    var boardingTime: String

    var fromCityLabel: String {
        Self.cityLabel(from: fromAirport)
    }

    var toCityLabel: String {
        Self.cityLabel(from: toAirport)
    }

    static func cityLabel(from airport: String) -> String {
        let trimmed = airport.trimmingCharacters(in: .whitespaces)
        if let openParen = trimmed.firstIndex(of: "(") {
            return String(trimmed[..<openParen]).trimmingCharacters(in: .whitespaces)
        }
        return trimmed
    }

    static let mockSample: TicketInfo = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let date = calendar.date(from: DateComponents(year: 2026, month: 6, day: 10)) ?? Date()
        return TicketInfo(
            passengerName: "Aulia Badrulkamal",
            fromAirport: "Jakarta (CGK)",
            toAirport: "Bali (DPS)",
            departureDate: date,
            flightID: "QZ123",
            departureTime: "12:00",
            seat: "12E",
            gate: "18",
            boardingTime: "11:30"
        )
    }()
}
