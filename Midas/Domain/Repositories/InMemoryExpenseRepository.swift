//
//  InMemoryExpenseRepository.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class InMemoryExpenseRepository: ExpenseRepositoryProtocol {
    var expenses: [Expense] = []
    var categories: [ExpenseCategory] = []

    func addExpense(_ expense: Expense) async throws {
        expenses.append(expense)
    }

    func addCategory(_ category: ExpenseCategory) async throws {
        categories.append(category)
    }
}
