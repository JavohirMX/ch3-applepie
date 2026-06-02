import Foundation

/// Handles chat CRUD operations with the backend.
final class ChatService: Sendable {
    static let shared = ChatService()
    private let client = APIClient.shared

    private init() {}

    /// List chats for the current device user, optionally filtered by category.
    func listChats(category: String? = nil) async throws -> [ChatListItem] {
        var path = "/api/chats?is_active=true"
        if let category {
            path += "&category=\(category)"
        }
        return try await client.get(path)
    }

    /// Create a new chat from a completed context form.
    func createChat(
        category: String,
        formType: String,
        title: String,
        subtitle: String?,
        countryCode: String,
        contextAnswers: [String: String]?
    ) async throws -> ChatResponse {
        let body = ChatCreateRequest(
            category: category,
            formType: formType,
            title: title,
            subtitle: subtitle,
            countryCode: countryCode,
            contextAnswers: contextAnswers
        )
        return try await client.post("/api/chats", body: body)
    }

    /// Get a single chat by ID.
    func getChat(chatId: String) async throws -> ChatResponse {
        return try await client.get("/api/chats/\(chatId)")
    }

    /// Soft-delete a chat.
    func deleteChat(chatId: String) async throws {
        try await client.delete("/api/chats/\(chatId)")
    }
}
