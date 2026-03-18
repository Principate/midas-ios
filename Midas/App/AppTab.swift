//
//  AppTab.swift
//  Midas
//

import Foundation

enum AppTab: String, CaseIterable {
    case portfolio = "Overview"
    case accounts = "Accounts"
    case profile = "PROFILE"
    
    var iconName: String {
        switch self {
        case .portfolio: return "square.on.square"
        case .accounts: return "circle.lefthalf.filled"
        case .profile: return "person.fill"
        }
    }
}
