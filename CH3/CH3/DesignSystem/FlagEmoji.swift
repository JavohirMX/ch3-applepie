import Foundation

enum FlagEmoji {
    /// Converts an ISO 3166-1 alpha-2 code (e.g. "US") to a flag emoji.
    static func string(for countryCode: String) -> String {
        let code = countryCode.uppercased().filter(\.isLetter)
        guard code.count == 2 else { return "🏳️" }

        let base: UInt32 = 127397
        var flag = ""
        flag.reserveCapacity(2)

        for scalar in code.unicodeScalars {
            guard let regional = UnicodeScalar(base + scalar.value) else { return "🏳️" }
            flag.unicodeScalars.append(regional)
        }

        return flag
    }
}
