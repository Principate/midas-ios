//
//  HomeViewModelTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct HomeViewModelTests {

    @Test func test_init_shouldHaveEmptyAccounts() {
        let viewModel = HomeViewModel()
        #expect(viewModel.accounts.isEmpty)
    }

    @Test func test_init_netWorthShouldBeZero() {
        let viewModel = HomeViewModel()
        #expect(viewModel.netWorth == 0)
    }

    @Test func test_loadSampleAccounts_shouldPopulateFourAccounts() {
        let viewModel = HomeViewModel()
        viewModel.loadSampleAccounts()
        #expect(viewModel.accounts.count == 4)
    }

    @Test func test_loadSampleAccounts_shouldCalculateCorrectNetWorth() {
        let viewModel = HomeViewModel()
        viewModel.loadSampleAccounts()
        // 45,000 + 131,245.50 (EUR→USD) + 68,857 + 19,200 (GBP→USD)
        #expect(viewModel.netWorth == 264_302.50)
    }

    @Test func test_netWorth_usesUSDEquivalentWhenAvailable() {
        let viewModel = HomeViewModel()
        viewModel.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "€",
                balance: 100.00,
                usdEquivalent: 110.00,
                iconType: .euro
            )
        ]
        #expect(viewModel.netWorth == 110.00)
    }

    @Test func test_netWorth_usesBalanceWhenNoUSDEquivalent() {
        let viewModel = HomeViewModel()
        viewModel.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "$",
                balance: 500.00,
                iconType: .bank
            )
        ]
        #expect(viewModel.netWorth == 500.00)
    }

    @Test func test_formattedNetWorth_shouldSplitWholeAndDecimal() {
        let viewModel = HomeViewModel()
        viewModel.accounts = [
            Account(
                name: "Test",
                subtitle: "Test",
                currencySymbol: "$",
                balance: 1234.56,
                iconType: .bank
            )
        ]
        let formatted = viewModel.formattedNetWorth
        #expect(formatted.whole == "$1,234")
        #expect(formatted.decimal == ".56")
    }

    @Test func test_formattedBalance_shouldIncludeCurrencySymbol() {
        let viewModel = HomeViewModel()
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
        let viewModel = HomeViewModel()
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
        let viewModel = HomeViewModel()
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

    @Test func test_loadSampleAccounts_firstAccountIsGlobalChecking() {
        let viewModel = HomeViewModel()
        viewModel.loadSampleAccounts()
        let first = viewModel.accounts.first
        #expect(first?.name == "Global Checking")
        #expect(first?.subtitle == "USD Primary")
        #expect(first?.currencySymbol == "$")
        #expect(first?.balance == 45_000.00)
        #expect(first?.iconType == .bank)
    }
}
