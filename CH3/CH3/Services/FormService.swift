import Foundation

/// Handles form definitions and phrase suggestions from the backend.
final class FormService: Sendable {
    static let shared = FormService()
    private let client = APIClient.shared

    private init() {}

    /// Get the form definition (steps) for a given form type.
    func getFormDefinition(formType: String) async throws -> FormDefinitionResponse {
        return try await client.get("/api/forms/\(formType)")
    }

    /// Generate quick-reply phrase suggestions for a chat.
    func getSuggestions(chatId: String) async throws -> [String] {
        let response: SuggestionResponse = try await client.postEmptyBody("/api/chats/\(chatId)/suggestions")
        return response.phrases
    }
}
