//
//  InMemoryCategoryRepository.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class InMemoryCategoryRepository: CategoryRepositoryProtocol {
    var categories: [ExpenseCategory]

    init(categories: [ExpenseCategory] = []) {
        self.categories = categories
    }

    func loadCategories() async throws {
        // No-op for in-memory store
    }
}
