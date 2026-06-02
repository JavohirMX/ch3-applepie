import Foundation

// MARK: - Request

struct MessageCreateRequest: Encodable {
    let text: String
}

// MARK: - Single message response

struct MessageResponse: Decodable, Identifiable {
    let id: String
    let chatId: String
    let sender: String
    let text: String
    let isTranscribed: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case sender
        case text
        case isTranscribed = "is_transcribed"
        case createdAt = "created_at"
    }
}

// MARK: - Send message response (user + AI reply)

struct SendMessageResponse: Decodable {
    let userMessage: MessageResponse
    let aiMessage: MessageResponse

    enum CodingKeys: String, CodingKey {
        case userMessage = "user_message"
        case aiMessage = "ai_message"
    }
}
