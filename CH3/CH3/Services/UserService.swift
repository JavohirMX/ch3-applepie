import Foundation

/// Handles user registration and profile operations with the backend.
final class UserService: Sendable {
    static let shared = UserService()
    private let client = APIClient.shared

    private init() {}

    /// Register (or retrieve) a user by device ID.
    /// Returns `true` if newly created (201), `false` if already exists (200).
    func register(deviceId: String) async throws -> UserResponse {
        let body = UserRegisterRequest(deviceId: deviceId)
        return try await client.post("/api/users/register", body: body)
    }

    /// Fetch a user profile by ID.
    func getUser(userId: String) async throws -> UserResponse {
        return try await client.get("/api/users/\(userId)")
    }

    /// Update the display name and/or preferences for a user.
    func updateUser(userId: String, displayName: String?, preferences: [String: String]?) async throws -> UserResponse {
        let body = UserUpdateRequest(displayName: displayName, preferences: preferences)
        return try await client.post("/api/users/\(userId)", body: body)
    }
}
