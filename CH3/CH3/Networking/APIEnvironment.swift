import Foundation

enum APIEnvironment {
    /// Base URL for the Conversa backend.
    /// Change this when deploying to production.
    static let baseURL: String = {
        #if DEBUG
        return "http://localhost:8000"
        #else
        // TODO: Replace with production URL when ready
        return "http://localhost:8000"
        #endif
    }()
}
