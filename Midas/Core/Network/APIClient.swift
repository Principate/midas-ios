//
//  APIClient.swift
//  Midas
//

import Foundation

// MARK: - Network Error

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case unknown(String)
}

// MARK: - API Client Protocol

protocol APIClientProtocol: Sendable {
    func post<T: Encodable>(path: String, body: T) async throws -> Data
}

// MARK: - API Client

final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func post<T: Encodable>(path: String, body: T) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}
