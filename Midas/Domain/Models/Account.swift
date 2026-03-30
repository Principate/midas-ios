//
//  Account.swift
//  Midas
//

import Foundation

// MARK: - Account Icon

enum AccountIcon: String, CaseIterable, Codable {
    case bank = "building.columns"
    case euro = "eurosign"
    case chart = "chart.line.uptrend.xyaxis"
    case pound = "sterlingsign"
    case creditcard = "creditcard"
    case wallet = "wallet.bifold"

    var systemImageName: String { rawValue }
}

// MARK: - Account Color

enum AccountColor: String, CaseIterable {
    case black = "#000000"
    case darkGreen = "#263B2B"
    case navy = "#1B2A4A"
    case burgundy = "#5C1A1A"
    case gold = "#C2A059"
    case slate = "#4A4A4A"
    case teal = "#1A4A4A"
    case purple = "#3B1A5C"
}

// MARK: - Account Type

enum AccountType: String, CaseIterable, Equatable, Codable {
    case creditCard = "credit_card"
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

// MARK: - Account Info (Circe sealed trait encoding)

enum AccountInfo: Equatable {
    case creditCard(limit: Double, dueDate: Int, closeDate: Int)
    case savings(minimumAmount: Double, interestRate: Double)
    case checking(minimumAmount: Double, interestRate: Double, overdraftLimit: Double)

    static func `default`(for accountType: AccountType) -> AccountInfo {
        switch accountType {
        case .creditCard: return .creditCard(limit: 0, dueDate: 1, closeDate: 1)
        case .savings: return .savings(minimumAmount: 0, interestRate: 0)
        case .checking: return .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
        }
    }
}

// MARK: - AccountInfo + Codable

extension AccountInfo: Codable {

    private struct CreditCardRendition: Codable, Equatable {
        let limit: Double
        let dueDate: Int
        let closeDate: Int
    }

    private struct SavingsAccountRendition: Codable, Equatable {
        let minimumAmount: Double
        let interestRate: Double
    }

    private struct CheckingAccountRendition: Codable, Equatable {
        let minimumAmount: Double
        let interestRate: Double
        let overdraftLimit: Double
    }

    private enum CodingKeys: String, CodingKey {
        case creditCard = "CreditCardRendition"
        case savings = "SavingsAccountRendition"
        case checking = "CheckingAccountRendition"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try container.decodeIfPresent(CreditCardRendition.self, forKey: .creditCard) {
            self = .creditCard(limit: data.limit, dueDate: data.dueDate, closeDate: data.closeDate)
        } else if let data = try container.decodeIfPresent(SavingsAccountRendition.self, forKey: .savings) {
            self = .savings(minimumAmount: data.minimumAmount, interestRate: data.interestRate)
        } else if let data = try container.decodeIfPresent(CheckingAccountRendition.self, forKey: .checking) {
            self = .checking(minimumAmount: data.minimumAmount, interestRate: data.interestRate, overdraftLimit: data.overdraftLimit)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown AccountInfo variant")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .creditCard(let limit, let dueDate, let closeDate):
            try container.encode(CreditCardRendition(limit: limit, dueDate: dueDate, closeDate: closeDate), forKey: .creditCard)
        case .savings(let minimumAmount, let interestRate):
            try container.encode(SavingsAccountRendition(minimumAmount: minimumAmount, interestRate: interestRate), forKey: .savings)
        case .checking(let minimumAmount, let interestRate, let overdraftLimit):
            try container.encode(CheckingAccountRendition(minimumAmount: minimumAmount, interestRate: interestRate, overdraftLimit: overdraftLimit), forKey: .checking)
        }
    }
}

// MARK: - Account

struct Account: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let currency: String
    let initialBalance: Double
    let color: String
    let icon: String
    let accountType: AccountType
    let info: AccountInfo

    init(
        id: UUID = UUID(),
        name: String,
        currency: String,
        initialBalance: Double,
        color: String = "#000000",
        icon: String = AccountIcon.bank.rawValue,
        accountType: AccountType = .checking,
        info: AccountInfo = .default(for: .checking)
    ) {
        self.id = id
        self.name = name
        self.currency = currency
        self.initialBalance = initialBalance
        self.color = color
        self.icon = icon
        self.accountType = accountType
        self.info = info
    }

    var formattedSubtitle: String {
        return "\(currency) • \(accountType.displayName.uppercased())"
    }

    var currencySymbol: String {
        switch currency {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        case "CHF": return "CHF"
        default: return currency
        }
    }

    var accountIcon: AccountIcon {
        AccountIcon(rawValue: icon) ?? .bank
    }
}
