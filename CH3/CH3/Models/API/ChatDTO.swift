import Foundation

// MARK: - Request

struct ChatCreateRequest: Encodable {
    let category: String
    let formType: String
    let title: String
    let subtitle: String?
    let countryCode: String
    let contextAnswers: [String: String]?

    enum CodingKeys: String, CodingKey {
        case category
        case formType = "form_type"
        case title
        case subtitle
        case countryCode = "country_code"
        case contextAnswers = "context_answers"
    }
}

// MARK: - Response (full chat)

struct ChatResponse: Decodable, Identifiable {
    let id: String
    let userId: String
    let category: String
    let formType: String
    let title: String
    let subtitle: String?
    let countryCode: String
    let contextAnswers: [String: String]?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let chatTypeDisplay: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case category
        case formType = "form_type"
        case title
        case subtitle
        case countryCode = "country_code"
        case contextAnswers = "context_answers"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case chatTypeDisplay = "chat_type_display"
    }
}

// MARK: - List item (abbreviated)

struct ChatListItem: Decodable, Identifiable {
    let id: String
    let category: String
    let formType: String
    let title: String
    let subtitle: String?
    let countryCode: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case formType = "form_type"
        case title
        case subtitle
        case countryCode = "country_code"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
