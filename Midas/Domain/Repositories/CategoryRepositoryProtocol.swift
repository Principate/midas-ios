//
//  CategoryRepositoryProtocol.swift
//  Midas
//

import Foundation

@MainActor
protocol CategoryRepositoryProtocol: AnyObject {
    var categories: [ExpenseCategory] { get }
    func loadCategories() async throws
}
