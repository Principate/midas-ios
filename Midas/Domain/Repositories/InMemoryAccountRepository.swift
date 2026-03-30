//
//  InMemoryAccountRepository.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class InMemoryAccountRepository: AccountRepositoryProtocol {
    var accounts: [Account] = []

    func loadInitialAccounts() async throws {
        accounts = [
            Account(
                name: "Global Checking",
                currency: "USD",
                initialBalance: 45_000.00,
                color: "#000000",
                icon: AccountIcon.bank.rawValue,
                accountType: .checking,
                info: .checking(minimumAmount: 1000, interestRate: 0.5, overdraftLimit: 500)
            ),
            Account(
                name: "European Vault",
                currency: "EUR",
                initialBalance: 120_500.00,
                color: "#263B2B",
                icon: AccountIcon.euro.rawValue,
                accountType: .savings,
                info: .savings(minimumAmount: 5000, interestRate: 2.5)
            ),
            Account(
                name: "Bespoke Card",
                currency: "USD",
                initialBalance: 68_857.00,
                color: "#1B2A4A",
                icon: AccountIcon.creditcard.rawValue,
                accountType: .creditCard,
                info: .creditCard(limit: 50000, dueDate: 15, closeDate: 1)
            ),
            Account(
                name: "London Trust",
                currency: "GBP",
                initialBalance: 15_000.00,
                color: "#5C1A1A",
                icon: AccountIcon.pound.rawValue,
                accountType: .savings,
                info: .savings(minimumAmount: 2000, interestRate: 1.8)
            )
        ]
    }

    func addAccount(_ account: Account) async throws {
        accounts.append(account)
    }
}
