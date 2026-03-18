//
//  HomeViewModel.swift
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

@Observable
@MainActor
class HomeViewModel {
    var accounts: [Account] = []
    
    var netWorth: Double {
        accounts.reduce(0) { total, account in
            total + (account.usdEquivalent ?? account.balance)
        }
    }
    
    var formattedNetWorth: (whole: String, decimal: String) {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formatted = formatter.string(from: NSNumber(value: netWorth)) ?? "0.00"
        let parts = formatted.split(separator: ".", maxSplits: 1)
        let whole = String(parts.first ?? "0")
        let decimal = parts.count > 1 ? ".\(parts.last ?? "00")" : ".00"
        return (whole: "$\(whole)", decimal: decimal)
    }
    
    func loadSampleAccounts() {
        accounts = [
            Account(
                name: "Global Checking",
                subtitle: "USD Primary",
                currencySymbol: "$",
                balance: 45_000.00,
                iconType: .bank
            ),
            Account(
                name: "European Vault",
                subtitle: "EUR Holding",
                currencySymbol: "€",
                balance: 120_500.00,
                usdEquivalent: 131_245.50,
                iconType: .euro
            ),
            Account(
                name: "Bespoke Investments",
                subtitle: "Multi-Asset",
                currencySymbol: "$",
                balance: 68_857.00,
                iconType: .chart
            ),
            Account(
                name: "London Trust",
                subtitle: "GBP Reserve",
                currencySymbol: "£",
                balance: 15_000.00,
                usdEquivalent: 19_200.00,
                iconType: .pound
            )
        ]
    }
    
    func formattedBalance(for account: Account) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: account.balance)) ?? "0.00"
        return "\(account.currencySymbol)\(formatted)"
    }
    
    func formattedUSDEquivalent(for account: Account) -> String? {
        guard let usdEquivalent = account.usdEquivalent else { return nil }
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: usdEquivalent)) ?? "0.00"
        return "~$\(formatted)"
    }
}
