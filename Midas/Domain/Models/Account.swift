//
//  Account.swift
//  Midas
//

import Foundation

enum AccountIconType: String, CaseIterable {
    case bank
    case euro
    case chart
    case pound
    
    var systemImageName: String {
        switch self {
        case .bank: return "building.columns"
        case .euro: return "eurosign"
        case .chart: return "chart.line.uptrend.xyaxis"
        case .pound: return "sterlingsign"
        }
    }
}

struct Account: Identifiable, Equatable {
    let id: UUID
    let name: String
    let subtitle: String
    let currencySymbol: String
    let balance: Double
    let usdEquivalent: Double?
    let iconType: AccountIconType
    
    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        currencySymbol: String,
        balance: Double,
        usdEquivalent: Double? = nil,
        iconType: AccountIconType
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.currencySymbol = currencySymbol
        self.balance = balance
        self.usdEquivalent = usdEquivalent
        self.iconType = iconType
    }
}
