//
//  ExpenseRepositoryProtocol.swift
//  Midas
//

import Foundation

@MainActor
protocol ExpenseRepositoryProtocol: AnyObject {
    var expenses: [Expense] { get }
    var categories: [ExpenseCategory] { get }
    func addExpense(_ expense: Expense) async throws
    func addCategory(_ category: ExpenseCategory) async throws
}
