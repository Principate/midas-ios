//
//  InMemoryAccountRepository.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class InMemoryAccountRepository: AccountRepositoryProtocol {
    var accounts: [Account] = []

    func loadInitialAccounts() {
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

    func addAccount(_ account: Account) {
        accounts.append(account)
    }
}
