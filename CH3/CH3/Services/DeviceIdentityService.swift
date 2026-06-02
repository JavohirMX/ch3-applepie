import Foundation
import Security

/// Manages the device identity (UUID) stored in the Keychain.
/// Used as the `X-Device-Id` header for backend authentication.
final class DeviceIdentityService: Sendable {
    static let shared = DeviceIdentityService()

    private let serviceName = "com.conversa.device-identity"
    private let accountName = "conversa.deviceId"

    private init() {}

    /// Returns the device ID, generating and storing one if none exists.
    var deviceId: String {
        if let existing = readFromKeychain() {
            return existing
        }
        let newId = UUID().uuidString
        writeToKeychain(newId)
        return newId
    }

    // MARK: - Keychain operations

    private func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    private func writeToKeychain(_ value: String) {
        // Delete any existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new item
        guard let data = value.data(using: .utf8) else { return }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        SecItemAdd(addQuery as CFDictionary, nil)
    }
}
