import Foundation

// MARK: - Request

struct UserRegisterRequest: Encodable {
    let deviceId: String

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
    }
}

// MARK: - Response

struct UserResponse: Decodable, Identifiable {
    let id: String
    let deviceId: String
    let displayName: String?
    let preferences: [String: String]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case displayName = "display_name"
        case preferences
        case createdAt = "created_at"
    }
}

// MARK: - Update

struct UserUpdateRequest: Encodable {
    let displayName: String?
    let preferences: [String: String]?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case preferences
    }
}
