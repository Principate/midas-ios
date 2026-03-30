//
//  InMemoryAccountRepositoryTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct InMemoryAccountRepositoryTests {

    @Test func test_init_shouldHaveEmptyAccounts() {
        let repository = InMemoryAccountRepository()
        #expect(repository.accounts.isEmpty)
    }

    @Test func test_loadInitialAccounts_shouldPopulateFourAccounts() async throws {
        let repository = InMemoryAccountRepository()
        try await repository.loadInitialAccounts()
        #expect(repository.accounts.count == 4)
    }

    @Test func test_addAccount_shouldAppendToAccounts() async throws {
        let repository = InMemoryAccountRepository()
        let account = Account(
            name: "Test Account",
            currency: "USD",
            initialBalance: 1000.00,
            icon: AccountIcon.bank.rawValue,
            accountType: .checking,
            info: .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
        )
        try await repository.addAccount(account)
        #expect(repository.accounts.count == 1)
    }

    @Test func test_addAccount_shouldPreserveExistingAccounts() async throws {
        let repository = InMemoryAccountRepository()
        try await repository.loadInitialAccounts()
        let account = Account(
            name: "New Account",
            currency: "EUR",
            initialBalance: 500.00,
            icon: AccountIcon.euro.rawValue,
            accountType: .savings,
            info: .savings(minimumAmount: 0, interestRate: 0)
        )
        try await repository.addAccount(account)
        #expect(repository.accounts.count == 5)
    }

    @Test func test_addAccount_shouldStoreCorrectAccountData() async throws {
        let repository = InMemoryAccountRepository()
        let account = Account(
            name: "Savings",
            currency: "GBP",
            initialBalance: 25_000.00,
            color: "#5C1A1A",
            icon: AccountIcon.pound.rawValue,
            accountType: .savings,
            info: .savings(minimumAmount: 1000, interestRate: 2.5)
        )
        try await repository.addAccount(account)

        let stored = repository.accounts.last
        #expect(stored?.name == "Savings")
        #expect(stored?.accountType == .savings)
        #expect(stored?.currency == "GBP")
        #expect(stored?.initialBalance == 25_000.00)
        #expect(stored?.color == "#5C1A1A")
        #expect(stored?.icon == AccountIcon.pound.rawValue)
        #expect(stored?.info == .savings(minimumAmount: 1000, interestRate: 2.5))
    }
}
