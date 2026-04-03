//
//  ExpenseCategory.swift
//  Midas
//

import Foundation

struct ExpenseCategory: Identifiable, Equatable, Codable, Hashable {
    let id: String
    var name: String
    var color: String

    init(id: String = UUID().uuidString, name: String, color: String = "#000000") {
        self.id = id
        self.name = name
        self.color = color
    }
}
