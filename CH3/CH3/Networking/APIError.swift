import Foundation

enum APIError: LocalizedError {
    case network(URLError)
    case server(statusCode: Int, body: String?)
    case unauthorized
    case notFound
    case decoding(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .server(let code, _):
            return "Server error (code \(code)). Please try again later."
        case .unauthorized:
            return "Device not registered. Please restart the app."
        case .notFound:
            return "The requested resource was not found."
        case .decoding:
            return "Failed to process the server response."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network:
            return "Check your internet connection and try again."
        case .server:
            return "Our servers may be experiencing issues. Please try again in a moment."
        case .unauthorized:
            return "Your device session may have expired."
        case .notFound:
            return nil
        case .decoding, .unknown:
            return "Please try again. If the problem persists, contact support."
        }
    }
}
