//
//  HomeViewModel.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class HomeViewModel {
    private let accountRepository: AccountRepositoryProtocol

    var accounts: [Account] {
        accountRepository.accounts
    }

    init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }

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

    func loadAccounts() {
        accountRepository.loadInitialAccounts()
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
