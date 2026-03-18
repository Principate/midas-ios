//
//  AppTab.swift
//  Midas
//

import Foundation

enum AppTab: String, CaseIterable {
    case portfolio = "Overview"
    case allocations = "ALLOCATIONS"
    case profile = "PROFILE"
    
    var iconName: String {
        switch self {
        case .portfolio: return "square.on.square"
        case .allocations: return "circle.lefthalf.filled"
        case .profile: return "person.fill"
        }
    }
}
