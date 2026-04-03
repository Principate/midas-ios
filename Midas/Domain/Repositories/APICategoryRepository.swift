//
//  APICategoryRepository.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class APICategoryRepository: CategoryRepositoryProtocol {
    var categories: [ExpenseCategory] = []

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadCategories() async throws {
        let data = try await apiClient.get(path: "/api/v1/categories")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        categories = try decoder.decode([ExpenseCategory].self, from: data)
    }
}
