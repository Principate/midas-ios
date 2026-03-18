//
//  HomeViewModelTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct HomeViewModelTests {

    @Test func test_init_shouldHaveEmptyAccounts() {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        #expect(viewModel.accounts.isEmpty)
    }

    @Test func test_loadAccounts_shouldDelegateToRepository() {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        viewModel.loadAccounts()
        #expect(repository.loadInitialAccountsCallCount == 1)
    }

    @Test func test_accounts_shouldReflectRepositoryState() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "$",
                balance: 1000.00,
                iconType: .bank
            )
        ]
        let viewModel = HomeViewModel(accountRepository: repository)
        #expect(viewModel.accounts.count == 1)
        #expect(viewModel.accounts.first?.name == "Test")
    }

    @Test func test_init_netWorthShouldBeZero() {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        #expect(viewModel.netWorth == 0)
    }

    @Test func test_netWorth_usesUSDEquivalentWhenAvailable() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "€",
                balance: 100.00,
                usdEquivalent: 110.00,
                iconType: .euro
            )
        ]
        let viewModel = HomeViewModel(accountRepository: repository)
        #expect(viewModel.netWorth == 110.00)
    }

    @Test func test_netWorth_usesBalanceWhenNoUSDEquivalent() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "$",
                balance: 500.00,
                iconType: .bank
            )
        ]
        let viewModel = HomeViewModel(accountRepository: repository)
        #expect(viewModel.netWorth == 500.00)
    }

    @Test func test_formattedNetWorth_shouldSplitWholeAndDecimal() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "$",
                balance: 1234.56,
                iconType: .bank
            )
        ]
        let viewModel = HomeViewModel(accountRepository: repository)
        let formatted = viewModel.formattedNetWorth
        #expect(formatted.whole == "$1,234")
        #expect(formatted.decimal == ".56")
    }

    @Test func test_formattedBalance_shouldIncludeCurrencySymbol() {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        let account = Account(
            name: "Euro Account",
            subtitle: "EUR",
            currencySymbol: "€",
            balance: 120_500.00,
            iconType: .euro
        )
        let formatted = viewModel.formattedBalance(for: account)
        #expect(formatted == "€120,500.00")
    }

    @Test func test_formattedUSDEquivalent_shouldReturnNilWhenNoEquivalent() {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        let account = Account(
            name: "USD Account",
            subtitle: "USD",
            currencySymbol: "$",
            balance: 1000.00,
            iconType: .bank
        )
        #expect(viewModel.formattedUSDEquivalent(for: account) == nil)
    }

    @Test func test_formattedUSDEquivalent_shouldFormatWhenPresent() {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        let account = Account(
            name: "Euro Account",
            subtitle: "EUR",
            currencySymbol: "€",
            balance: 120_500.00,
            usdEquivalent: 131_245.50,
            iconType: .euro
        )
        let formatted = viewModel.formattedUSDEquivalent(for: account)
        #expect(formatted == "~$131,245.50")
    }
}
