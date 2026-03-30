//
//  MockAPIClient.swift
//  MidasTests
//

import Foundation
@testable import Midas

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var getCallCount = 0
    var lastGetPath: String?
    var stubbedGetResult: Data = Data()
    var getError: Error?

    var postCallCount = 0
    var lastPostPath: String?
    var lastPostBodyData: Data?
    var stubbedPostResult: Data = Data()
    var postError: Error?

    func get(path: String) async throws -> Data {
        getCallCount += 1
        lastGetPath = path
        if let error = getError {
            throw error
        }
        return stubbedGetResult
    }

    func post<T: Encodable>(path: String, body: T) async throws -> Data {
        postCallCount += 1
        lastPostPath = path

        let encoder = JSONEncoder()
        lastPostBodyData = try encoder.encode(body)

        if let error = postError {
            throw error
        }
        return stubbedPostResult
    }
}
