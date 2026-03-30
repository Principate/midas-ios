//
//  APIClient.swift
//  Midas
//

import Foundation
import OSLog

// MARK: - Network Error

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case unauthorized
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let statusCode):
            return "Server error (HTTP \(statusCode))."
        case .decodingError:
            return "Failed to decode the server response."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Token Provider

typealias TokenProvider = @Sendable () async throws -> String?

// MARK: - API Client Protocol

protocol APIClientProtocol: Sendable {
    func get(path: String) async throws -> Data
    func post<T: Encodable>(path: String, body: T) async throws -> Data
}

// MARK: - API Client

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: TokenProvider
    private let logger = Logger(subsystem: "com.midas.app", category: "Network")

    init(baseURL: URL, session: URLSession = .shared, tokenProvider: @escaping TokenProvider) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }

    func get(path: String) async throws -> Data {
        let request = try await makeRequest(path: path, method: "GET")
        return try await perform(request: request)
    }

    func post<T: Encodable>(path: String, body: T) async throws -> Data {
        var request = try await makeRequest(path: path, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        return try await perform(request: request)
    }

    // MARK: - Private

    private func makeRequest(path: String, method: String) async throws -> URLRequest {
        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let trimmedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(base)/\(trimmedPath)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method

        if let token = try await tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func perform(request: URLRequest) async throws -> Data {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "unknown"

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            logger.error("\(method) \(url) — transport error: \(error.localizedDescription)")
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("\(method) \(url) — invalid response (not HTTP)")
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            logger.error("\(method) \(url) — HTTP \(httpResponse.statusCode): \(body)")
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}
