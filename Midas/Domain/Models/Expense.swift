//
//  Expense.swift
//  Midas
//

import Foundation

struct Expense: Identifiable, Equatable, Codable {
    let id: UUID
    var amount: Double
    var currency: String
    var accountId: UUID
    var categoryId: String
    var title: String
    var tags: [String]
    var date: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        currency: String,
        accountId: UUID,
        categoryId: String,
        title: String = "",
        tags: [String] = [],
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.accountId = accountId
        self.categoryId = categoryId
        self.title = title
        self.tags = tags
        self.date = date
    }
}
