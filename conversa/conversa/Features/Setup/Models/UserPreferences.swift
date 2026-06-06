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
    case lactose = "Lactose intolerance"
    case gluten = "Gluten intolerance"
    case vegetarian = "Vegetarianism"
    case vegan = "Veganism"
    case diabetes = "Diabetes"
    case allergy = "Allergy"

    var id: String { rawValue }
}

enum SeatPreferenceOption: String, CaseIterable, Identifiable {
    case window = "Window"
    case middle = "Middle"
    case aisle = "Aisle"

    var id: String { rawValue }
}

enum DisabilityOption: String, CaseIterable, Identifiable {
    case snhl = "SNHL"
    case conductive = "Conductive"
    case mixed = "Mixed"
    case ansnd = "ANSD"

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
