//
//  MockExpenseRepository.swift
//  MidasTests
//

import Foundation
@testable import Midas

@MainActor
class MockExpenseRepository: ExpenseRepositoryProtocol {
    var expenses: [Expense] = []
    var categories: [ExpenseCategory] = []

    var addExpenseCallCount = 0
    var addCategoryCallCount = 0
    var shouldThrowOnAdd = false

    func addExpense(_ expense: Expense) async throws {
        addExpenseCallCount += 1
        if shouldThrowOnAdd {
            throw NSError(domain: "MockError", code: 1)
        }
        expenses.append(expense)
    }

    func addCategory(_ category: ExpenseCategory) async throws {
        addCategoryCallCount += 1
        if shouldThrowOnAdd {
            throw NSError(domain: "MockError", code: 1)
        }
        categories.append(category)
    }
}
