import Foundation

// MARK: - Form definition

struct FormDefinitionResponse: Decodable {
    let formType: String
    let title: String
    let iconSystemName: String
    let steps: [FormStepResponse]

    enum CodingKeys: String, CodingKey {
        case formType = "form_type"
        case title
        case iconSystemName = "icon_system_name"
        case steps
    }
}

struct FormStepResponse: Decodable {
    let index: Int
    let prompt: String
    let inputKind: String
    let placeholder: String

    enum CodingKeys: String, CodingKey {
        case index
        case prompt
        case inputKind = "input_kind"
        case placeholder
    }
}

// MARK: - Suggestions

struct SuggestionResponse: Decodable {
    let phrases: [String]
}
