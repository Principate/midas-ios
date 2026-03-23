//
//  MockAPIClient.swift
//  MidasTests
//

import Foundation
@testable import Midas

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var postCallCount = 0
    var lastPostPath: String?
    var lastPostBodyData: Data?
    var stubbedPostResult: Data = Data()
    var postError: Error?

    func post<T: Encodable>(path: String, body: T) async throws -> Data {
        postCallCount += 1
        lastPostPath = path

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        lastPostBodyData = try encoder.encode(body)

        if let error = postError {
            throw error
        }
        return stubbedPostResult
    }
}
