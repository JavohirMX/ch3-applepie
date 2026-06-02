import Foundation

/// Shared HTTP client for the Conversa API.
/// Attaches `X-Device-Id` to every request automatically.
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private var deviceId: String {
        DeviceIdentityService.shared.deviceId
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Public methods

    func get<T: Decodable>(_ path: String) async throws -> T {
        let request = try makeRequest(path: path, method: "GET")
        return try await perform(request)
    }

    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        let request = try makeRequest(path: path, method: "POST", body: body)
        return try await perform(request)
    }

    func postEmptyBody<T: Decodable>(_ path: String) async throws -> T {
        let request = try makeRequest(path: path, method: "POST")
        return try await perform(request)
    }

    func delete(_ path: String) async throws {
        let request = try makeRequest(path: path, method: "DELETE")
        _ = try await performVoid(request)
    }

    // MARK: - Request building

    private func makeRequest(path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: APIEnvironment.baseURL + path) else {
            throw APIError.unknown(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-Id")
        return request
    }

    private func makeRequest<B: Encodable>(path: String, method: String, body: B) throws -> URLRequest {
        var request = try makeRequest(path: path, method: method)
        request.httpBody = try encoder.encode(body)
        return request
    }

    // MARK: - Response handling

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await performVoid(request)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    @discardableResult
    private func performVoid(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIError.network(error)
        } catch {
            throw APIError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            return (data, httpResponse)
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            let body = String(data: data, encoding: .utf8)
            throw APIError.server(statusCode: httpResponse.statusCode, body: body)
        }
    }
}
