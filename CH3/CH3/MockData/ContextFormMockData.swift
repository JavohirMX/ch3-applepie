import Foundation

enum ContextFormMockData {
    static func definition(for formType: ContextFormType) -> ContextFormDefinition {
        ContextFormDefinition(formType: formType, steps: steps(for: formType))
    }

    static func steps(for formType: ContextFormType) -> [ContextFormStep] {
        switch formType {
        case .airport:
            return [
                step("What airline and flight are you taking?", placeholder: "e.g. Garuda GA402"),
                step("Where are you flying from and to?", placeholder: "e.g. Bali to Jakarta"),
                step("What seat do you prefer?", placeholder: "Window / Aisle"),
                step("Do you have any food preferences or allergies?", placeholder: "Your answer"),
                step("Are you carrying check-in luggage?", placeholder: "Yes / No"),
                step("Is there anything you usually need help communicating?", placeholder: "Your answer"),
                step("Add anything important AI should remember for this trip.", placeholder: "Your answer")
            ]
        case .cab:
            return [
                step("Where are you going today?", placeholder: "Destination"),
                step("Do you usually prefer silent rides?", placeholder: "Yes / No"),
                step("Do you need frequent stops or route changes?", placeholder: "Your answer"),
                step("Are you carrying luggage or large bags?", placeholder: "Your answer"),
                step("Is there anything drivers often misunderstand about your instructions?", placeholder: "Your answer"),
                step("What payment method will you use?", placeholder: "Cash / Card / App"),
                step("Add anything important AI should remember for this ride.", placeholder: "Your answer")
            ]
        case .bus:
            return [
                step("What is your destination?", placeholder: "Destination"),
                step("Which bus/company/route are you taking?", placeholder: "Route name"),
                step("Do you prefer window or aisle seats?", placeholder: "Window / Aisle"),
                step("Do you usually ask drivers about stops or timings?", placeholder: "Your answer"),
                step("Are you carrying luggage?", placeholder: "Your answer"),
                step("Is there anything important about this journey AI should know?", placeholder: "Your answer"),
                step("Add anything AI should help communicate during the trip.", placeholder: "Your answer")
            ]
        case .hotel:
            return [
                step("What hotel are you staying at?", placeholder: "Hotel name"),
                step("What name is the booking under?", placeholder: "Booking name"),
                step("What are your check-in and check-out dates?", placeholder: "Dates", inputKind: .dateRange),
                step("Do you have room preferences?", placeholder: "Your preferences"),
                step("Do you have food preferences or allergies?", placeholder: "Your answer"),
                step("What do you usually need help communicating at hotels?", placeholder: "Your answer"),
                step("Add anything important AI should remember during your stay.", placeholder: "Your answer")
            ]
        case .store:
            return [
                step("What are you shopping for today?", placeholder: "Items"),
                step("What size, color, or model are you looking for?", placeholder: "Details"),
                step("What is your budget?", placeholder: "Budget"),
                step("Do you prefer premium or affordable options?", placeholder: "Your preference"),
                step("What questions do you usually need help asking in stores?", placeholder: "Your answer"),
                step("Are there any products or materials you avoid?", placeholder: "Your answer"),
                step("Add anything AI should remember while helping you shop.", placeholder: "Your answer")
            ]
        case .miscGeneric:
            return [
                step("What do you need help with today?", placeholder: "Topic"),
                step("Where are you right now?", placeholder: "Location"),
                step("What should AI help you communicate?", placeholder: "Your answer")
            ]
        }
    }

    private static func step(
        _ prompt: String,
        placeholder: String,
        inputKind: ContextInputKind = .text
    ) -> ContextFormStep {
        ContextFormStep(prompt: prompt, inputKind: inputKind, placeholder: placeholder)
    }
}
