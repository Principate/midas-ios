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

    @Test func test_loadInitialAccounts_shouldPopulateFourAccounts() {
        let repository = InMemoryAccountRepository()
        repository.loadInitialAccounts()
        #expect(repository.accounts.count == 4)
    }

    @Test func test_addAccount_shouldAppendToAccounts() {
        let repository = InMemoryAccountRepository()
        let account = Account(
            name: "Test Account",
            accountType: .checking,
            currencySymbol: "$",
            balance: 1000.00,
            iconType: .bank
        )
        repository.addAccount(account)
        #expect(repository.accounts.count == 1)
    }

    @Test func test_addAccount_shouldPreserveExistingAccounts() {
        let repository = InMemoryAccountRepository()
        repository.loadInitialAccounts()
        let account = Account(
            name: "New Account",
            accountType: .savings,
            currencySymbol: "€",
            balance: 500.00,
            iconType: .euro
        )
        repository.addAccount(account)
        #expect(repository.accounts.count == 5)
    }

    @Test func test_addAccount_shouldStoreCorrectAccountData() {
        let repository = InMemoryAccountRepository()
        let account = Account(
            name: "Savings",
            accountType: .savings,
            currencySymbol: "£",
            balance: 25_000.00,
            usdEquivalent: 32_000.00,
            iconType: .pound
        )
        repository.addAccount(account)

        let stored = repository.accounts.last
        #expect(stored?.name == "Savings")
        #expect(stored?.accountType == .savings)
        #expect(stored?.currencySymbol == "£")
        #expect(stored?.balance == 25_000.00)
        #expect(stored?.usdEquivalent == 32_000.00)
        #expect(stored?.iconType == .pound)
    }
}
