//
//  AppTab.swift
//  Midas
//

import Foundation

enum AppTab: String, CaseIterable {
    case portfolio
    case accounts
    case profile

    var title: String {
        switch self {
        case .portfolio: return "Portfolio"
        case .accounts: return "Accounts"
        case .profile: return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .portfolio: return "chart.pie"
        case .accounts: return "building.columns"
        case .profile: return "person"
        }
    }
}
