//
//  Account.swift
//  Midas
//

import Foundation

// MARK: - Account Icon Type

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

// MARK: - Account Type

enum AccountType: String, CaseIterable, Equatable {
    case creditCard
    case savings
    case checking

    var displayName: String {
        switch self {
        case .creditCard: return "Credit Card"
        case .savings: return "Savings"
        case .checking: return "Checking"
        }
    }
}

// MARK: - Account Type Details

enum AccountTypeDetails: Equatable {
    case creditCard(creditLimit: Double, statementCloseDate: Date, paymentDueDate: Date)
    case savings(minimumBalance: Double?)
    case checking(minimumBalance: Double?)

    var accountType: AccountType {
        switch self {
        case .creditCard: return .creditCard
        case .savings: return .savings
        case .checking: return .checking
        }
    }
}

// MARK: - Account

struct Account: Identifiable, Equatable {
    let id: UUID
    let name: String
    let accountType: AccountType
    let currencySymbol: String
    let balance: Double
    let usdEquivalent: Double?
    let iconType: AccountIconType
    let typeDetails: AccountTypeDetails?
    
    init(
        id: UUID = UUID(),
        name: String,
        accountType: AccountType,
        currencySymbol: String,
        balance: Double,
        usdEquivalent: Double? = nil,
        iconType: AccountIconType,
        typeDetails: AccountTypeDetails? = nil
    ) {
        self.id = id
        self.name = name
        self.accountType = accountType
        self.currencySymbol = currencySymbol
        self.balance = balance
        self.usdEquivalent = usdEquivalent
        self.iconType = iconType
        self.typeDetails = typeDetails
    }

    var formattedSubtitle: String {
        let currencyCode: String
        switch currencySymbol {
        case "$": currencyCode = "USD"
        case "€": currencyCode = "EUR"
        case "£": currencyCode = "GBP"
        case "¥": currencyCode = "JPY"
        case "CHF": currencyCode = "CHF"
        default: currencyCode = currencySymbol
        }
        return "\(currencyCode) • \(accountType.displayName.uppercased())"
    }
}
