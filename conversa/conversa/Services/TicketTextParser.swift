import Foundation

enum TicketTextParser {
    static func parse(_ text: String) -> TicketInfo {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let upperText = text.uppercased()

        return TicketInfo(
            passengerName: extractPassengerName(from: lines, upperText: upperText),
            fromAirport: extractAirport(from: lines, upperText: upperText, direction: .from),
            toAirport: extractAirport(from: lines, upperText: upperText, direction: .to),
            departureDate: extractDate(from: text) ?? Date(),
            flightID: extractFlightID(from: upperText),
            departureTime: extractLabeledTime(from: upperText, labels: ["DEP", "DEPART", "STD", "DEPARTURE"]),
            seat: extractSeat(from: upperText),
            gate: extractGate(from: upperText),
            boardingTime: extractLabeledTime(from: upperText, labels: ["BOARD", "BOARDING", "BDD"])
        )
    }

    private enum AirportDirection {
        case from, to
    }

    private static func extractPassengerName(from lines: [String], upperText: String) -> String {
        let labelPatterns = ["PASSENGER", "PASSENGER NAME", "NAME", "PAX"]
        for (index, line) in lines.enumerated() {
            let upperLine = line.uppercased()
            for label in labelPatterns {
                if upperLine.contains(label) {
                    if let colonIndex = line.firstIndex(of: ":") {
                        let afterColon = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        if isPlausibleName(afterColon) { return afterColon }
                    }
                    if index + 1 < lines.count {
                        let next = lines[index + 1]
                        if isPlausibleName(next) { return next }
                    }
                }
            }
        }

        return lines
            .filter { isPlausibleName($0) && !$0.uppercased().contains("BOARDING") }
            .max(by: { $0.count < $1.count }) ?? ""
    }

    private static func isPlausibleName(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 3 else { return false }
        let words = trimmed.split(separator: " ")
        guard words.count >= 2 else { return false }
        let letterCount = trimmed.filter { $0.isLetter || $0.isWhitespace }.count
        return Double(letterCount) / Double(trimmed.count) > 0.85
    }

    private static func extractFlightID(from upperText: String) -> String {
        let labeledPattern = #"(?:FLIGHT|FLT)\s*:?\s*([A-Z]{2}\s?\d{1,4})"#
        if let match = firstMatch(in: upperText, pattern: labeledPattern, group: 1) {
            return normalizeFlightID(match)
        }

        let standalonePattern = #"\b([A-Z]{2}\s?\d{1,4})\b"#
        if let match = firstMatch(in: upperText, pattern: standalonePattern, group: 1) {
            return normalizeFlightID(match)
        }

        return ""
    }

    private static func normalizeFlightID(_ value: String) -> String {
        value.replacingOccurrences(of: " ", with: "").uppercased()
    }

    private static func extractSeat(from upperText: String) -> String {
        let labeledPattern = #"SEAT\s*:?\s*(\d{1,2}[A-K])"#
        if let match = firstMatch(in: upperText, pattern: labeledPattern, group: 1) {
            return match.uppercased()
        }

        let standalonePattern = #"\b(\d{1,2}[A-K])\b"#
        return firstMatch(in: upperText, pattern: standalonePattern, group: 1)?.uppercased() ?? ""
    }

    private static func extractGate(from upperText: String) -> String {
        let pattern = #"(?:GATE|GT)\s*:?\s*(\d+[A-Z]?)"#
        return firstMatch(in: upperText, pattern: pattern, group: 1) ?? ""
    }

    private static func extractLabeledTime(from upperText: String, labels: [String]) -> String {
        for label in labels {
            let pattern = "\(label)\\s*:?\\s*(\\d{1,2}:\\d{2})"
            if let match = firstMatch(in: upperText, pattern: pattern, group: 1) {
                return match
            }
        }
        return ""
    }

    private static func extractAirport(
        from lines: [String],
        upperText: String,
        direction: AirportDirection
    ) -> String {
        let labelGroups: [String]
        switch direction {
        case .from:
            labelGroups = ["FROM", "ORIGIN", "DEPART", "DEP"]
        case .to:
            labelGroups = ["TO", "DEST", "DESTINATION", "ARR"]
        }

        for line in lines {
            let upperLine = line.uppercased()
            for label in labelGroups {
                if upperLine.contains(label) {
                    if let airport = airportFromLine(line) {
                        return airport
                    }
                }
            }
        }

        let codes = allIATACodes(in: upperText)
        switch direction {
        case .from:
            return codes.first.map { formatAirport(code: $0, in: lines) } ?? ""
        case .to:
            return codes.dropFirst().first.map { formatAirport(code: $0, in: lines) } ?? codes.last.map { formatAirport(code: $0, in: lines) } ?? ""
        }
    }

    private static func airportFromLine(_ line: String) -> String? {
        let upperLine = line.uppercased()
        guard let code = firstMatch(in: upperLine, pattern: #"\b([A-Z]{3})\b"#, group: 1) else {
            return nil
        }
        return formatAirport(code: code, in: [line])
    }

    private static func allIATACodes(in upperText: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: #"\b([A-Z]{3})\b"#) else { return [] }
        let range = NSRange(upperText.startIndex..., in: upperText)
        let matches = regex.matches(in: upperText, range: range)
        var seen = Set<String>()
        var codes: [String] = []

        let excluded = Set(["THE", "AND", "FOR", "NOT", "ALL", "PDF", "PNG", "JPG"])

        for match in matches {
            guard let matchRange = Range(match.range(at: 1), in: upperText) else { continue }
            let code = String(upperText[matchRange])
            guard !excluded.contains(code), seen.insert(code).inserted else { continue }
            codes.append(code)
        }

        return codes
    }

    private static func formatAirport(code: String, in lines: [String]) -> String {
        for line in lines {
            let upperLine = line.uppercased()
            guard upperLine.contains(code) else { continue }

            if let openParen = line.firstIndex(of: "("),
               let closeParen = line.firstIndex(of: ")"),
               openParen < closeParen {
                let cityPart = String(line[..<openParen]).trimmingCharacters(in: .whitespaces)
                if !cityPart.isEmpty, cityPart.count > 2 {
                    return "\(cityPart) (\(code))"
                }
            }

            let withoutCode = line.replacingOccurrences(of: "(\(code))", with: "")
                .replacingOccurrences(of: code, with: "")
                .trimmingCharacters(in: .whitespaces)
            if withoutCode.count > 2, withoutCode.uppercased() != withoutCode || withoutCode.contains(" ") {
                return "\(withoutCode) (\(code))"
            }
        }

        return code
    }

    private static func extractDate(from text: String) -> Date? {
        let formatters: [DateFormatter] = {
            let formats = ["dd MMM yyyy", "dd MMM yy", "yyyy-MM-dd", "MM/dd/yyyy", "dd/MM/yyyy", "MMM dd, yyyy"]
            return formats.map { format in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = format
                return formatter
            }
        }()

        for formatter in formatters {
            if let date = formatter.date(from: text) {
                return date
            }
        }

        for line in text.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            for formatter in formatters {
                if let date = formatter.date(from: trimmed) {
                    return date
                }
            }
        }

        return nil
    }

    private static func firstMatch(in text: String, pattern: String, group: Int) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let matchRange = Range(match.range(at: group), in: text) else {
            return nil
        }
        return String(text[matchRange]).trimmingCharacters(in: .whitespaces)
    }
}
