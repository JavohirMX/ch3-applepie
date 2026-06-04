import Foundation

struct UserPreferences: Codable, Equatable {
    var mealPreference: String
    var seatPreference: String
    var emergencyCountryCode: String
    var emergencyPhone: String
    var disabilityType: String

    static let empty = UserPreferences(
        mealPreference: "",
        seatPreference: "",
        emergencyCountryCode: "+62",
        emergencyPhone: "",
        disabilityType: ""
    )

    var emergencyContactDisplay: String {
        let phone = emergencyPhone.trimmingCharacters(in: .whitespaces)
        guard !phone.isEmpty else { return "Not set" }
        return "\(emergencyCountryCode) \(phone)"
    }
}

enum MealPreferenceOption: String, CaseIterable, Identifiable {
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case halal = "Halal"
    case kosher = "Kosher"
    case none = "No restriction"

    var id: String { rawValue }
}

enum SeatPreferenceOption: String, CaseIterable, Identifiable {
    case window = "Window Seat"
    case aisle = "Aisle Seat"
    case middle = "Middle Seat"
    case noPreference = "No preference"

    var id: String { rawValue }
}

enum DisabilityOption: String, CaseIterable, Identifiable {
    case none = "None"
    case deaf = "Deaf / Hard of Hearing"
    case mobility = "Mobility"
    case visual = "Visual"
    case cognitive = "Cognitive"
    case other = "Other"

    var id: String { rawValue }
}

enum CountryCodeOption: String, CaseIterable, Identifiable {
    case indonesia = "+62"
    case singapore = "+65"
    case malaysia = "+60"
    case australia = "+61"
    case usa = "+1"
    case uk = "+44"

    var id: String { rawValue }
}
