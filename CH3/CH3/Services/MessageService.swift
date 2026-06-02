import Foundation

/// Handles message sending and history retrieval with the backend.
final class MessageService: Sendable {
    static let shared = MessageService()
    private let client = APIClient.shared

    private init() {}

    /// Get paginated message history for a chat.
    func getMessageHistory(chatId: String, limit: Int = 50, offset: Int = 0) async throws -> [MessageResponse] {
        let path = "/api/chats/\(chatId)/messages?limit=\(limit)&offset=\(offset)"
        return try await client.get(path)
    }

    /// Send a user message and receive an AI reply.
    func sendMessage(chatId: String, text: String) async throws -> SendMessageResponse {
        let body = MessageCreateRequest(text: text)
        return try await client.post("/api/chats/\(chatId)/messages", body: body)
    }
}
