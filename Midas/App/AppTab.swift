//
//  AppTab.swift
//  Midas
//

import Foundation

enum AppTab: String, CaseIterable {
    case portfolio
    case accounts
    case createExpense
    case budget
    case profile

    var title: String {
        switch self {
        case .portfolio: return "Overview"
        case .accounts: return "Accounts"
        case .createExpense: return "Add Expense"
        case .profile: return "Profile"
        case .budget: return "Budgets"
        }
    }

    var iconName: String {
        switch self {
        case .portfolio: return "chart.pie"
        case .accounts: return "building.columns"
        case .createExpense: return "plus"
        case .profile: return "person"
        case .budget: return "chart.pie"
        }
    }
}
