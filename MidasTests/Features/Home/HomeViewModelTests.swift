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

    @Test func test_loadAccounts_shouldDelegateToRepository() async {
        let repository = MockAccountRepository()
        let viewModel = HomeViewModel(accountRepository: repository)
        await viewModel.loadAccounts()
        #expect(repository.loadInitialAccountsCallCount == 1)
    }

    @Test func test_accounts_shouldReflectRepositoryState() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                currency: "USD",
                initialBalance: 1000.00,
                icon: AccountIcon.bank.rawValue,
                accountType: .checking,
                info: .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
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

    @Test func test_netWorth_usesInitialBalance() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                currency: "EUR",
                initialBalance: 110.00,
                icon: AccountIcon.euro.rawValue,
                accountType: .savings,
                info: .savings(minimumAmount: 0, interestRate: 0)
            )
        ]
        let viewModel = HomeViewModel(accountRepository: repository)
        #expect(viewModel.netWorth == 110.00)
    }

    @Test func test_formattedNetWorth_shouldSplitWholeAndDecimal() {
        let repository = MockAccountRepository()
        repository.accounts = [
            Account(
                name: "Test",
                currency: "USD",
                initialBalance: 1234.56,
                icon: AccountIcon.bank.rawValue,
                accountType: .checking,
                info: .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
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
            currency: "EUR",
            initialBalance: 120_500.00,
            icon: AccountIcon.euro.rawValue,
            accountType: .savings,
            info: .savings(minimumAmount: 0, interestRate: 0)
        )
        let formatted = viewModel.formattedBalance(for: account)
        #expect(formatted == "€120,500.00")
    }
}
