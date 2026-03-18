//
//  CreateAccountViewModelTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct CreateAccountViewModelTests {

    // MARK: - Initial State

    @Test func test_init_shouldHaveEmptyName() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(viewModel.name.isEmpty)
    }

    @Test func test_init_shouldHaveEmptySubtitle() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(viewModel.subtitle.isEmpty)
    }

    @Test func test_init_shouldHaveDefaultCurrencySymbolDollar() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(viewModel.currencySymbol == "$")
    }

    @Test func test_init_shouldHaveEmptyBalanceString() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(viewModel.balanceString.isEmpty)
    }

    @Test func test_init_shouldHaveDefaultIconTypeBank() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(viewModel.iconType == .bank)
    }

    @Test func test_init_formShouldBeInvalid() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(!viewModel.isFormValid)
    }

    @Test func test_init_didSaveShouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        #expect(!viewModel.didSave)
    }

    // MARK: - Validation

    @Test func test_isFormValid_whenNameIsEmpty_shouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = ""
        viewModel.subtitle = "Checking"
        viewModel.balanceString = "1000"
        #expect(!viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenSubtitleIsEmpty_shouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "My Account"
        viewModel.subtitle = ""
        viewModel.balanceString = "1000"
        #expect(!viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenCurrencySymbolIsEmpty_shouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "My Account"
        viewModel.subtitle = "Checking"
        viewModel.currencySymbol = ""
        viewModel.balanceString = "1000"
        #expect(!viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenBalanceStringIsNotANumber_shouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "My Account"
        viewModel.subtitle = "Checking"
        viewModel.balanceString = "abc"
        #expect(!viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenBalanceIsNegative_shouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "My Account"
        viewModel.subtitle = "Checking"
        viewModel.balanceString = "-100"
        #expect(!viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenAllFieldsAreValid_shouldBeTrue() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "My Account"
        viewModel.subtitle = "Checking"
        viewModel.balanceString = "1000"
        #expect(viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenBalanceIsZero_shouldBeTrue() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "My Account"
        viewModel.subtitle = "Checking"
        viewModel.balanceString = "0"
        #expect(viewModel.isFormValid)
    }

    @Test func test_isFormValid_whenNameIsOnlyWhitespace_shouldBeFalse() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.name = "   "
        viewModel.subtitle = "Checking"
        viewModel.balanceString = "1000"
        #expect(!viewModel.isFormValid)
    }

    // MARK: - Parsed Balance

    @Test func test_parsedBalance_whenBalanceStringIsValid_shouldReturnDouble() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.balanceString = "1234.56"
        #expect(viewModel.parsedBalance == 1234.56)
    }

    @Test func test_parsedBalance_whenBalanceStringIsEmpty_shouldReturnNil() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.balanceString = ""
        #expect(viewModel.parsedBalance == nil)
    }

    @Test func test_parsedBalance_whenBalanceStringIsNotNumeric_shouldReturnNil() {
        let viewModel = CreateAccountViewModel(accountRepository: MockAccountRepository())
        viewModel.balanceString = "not a number"
        #expect(viewModel.parsedBalance == nil)
    }

    // MARK: - Save Account

    @Test func test_saveAccount_shouldCallRepositoryAddAccount() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Savings"
        viewModel.subtitle = "High Yield"
        viewModel.balanceString = "5000"
        viewModel.saveAccount()
        #expect(repository.addAccountCallCount == 1)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectName() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Savings"
        viewModel.subtitle = "High Yield"
        viewModel.balanceString = "5000"
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.name == "Savings")
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectSubtitle() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Savings"
        viewModel.subtitle = "High Yield"
        viewModel.balanceString = "5000"
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.subtitle == "High Yield")
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectCurrencySymbol() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Euro Fund"
        viewModel.subtitle = "Savings"
        viewModel.currencySymbol = "€"
        viewModel.balanceString = "3000"
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.currencySymbol == "€")
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectBalance() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Savings"
        viewModel.subtitle = "High Yield"
        viewModel.balanceString = "5000.75"
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.balance == 5000.75)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectIconType() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Euro Fund"
        viewModel.subtitle = "Savings"
        viewModel.balanceString = "3000"
        viewModel.iconType = .euro
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.iconType == .euro)
    }

    @Test func test_saveAccount_shouldSetDidSaveToTrue() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Savings"
        viewModel.subtitle = "High Yield"
        viewModel.balanceString = "5000"
        viewModel.saveAccount()
        #expect(viewModel.didSave)
    }

    @Test func test_saveAccount_whenFormIsInvalid_shouldNotCallRepository() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.saveAccount()
        #expect(repository.addAccountCallCount == 0)
        #expect(!viewModel.didSave)
    }

    @Test func test_saveAccount_shouldTrimWhitespaceFromName() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "  Savings  "
        viewModel.subtitle = "High Yield"
        viewModel.balanceString = "5000"
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.name == "Savings")
    }

    @Test func test_saveAccount_shouldTrimWhitespaceFromSubtitle() {
        let repository = MockAccountRepository()
        let viewModel = CreateAccountViewModel(accountRepository: repository)
        viewModel.name = "Savings"
        viewModel.subtitle = "  High Yield  "
        viewModel.balanceString = "5000"
        viewModel.saveAccount()
        #expect(repository.lastAddedAccount?.subtitle == "High Yield")
    }

    // MARK: - Currency Symbol Options

    @Test func test_currencySymbolOptions_shouldContainCommonSymbols() {
        let options = CreateAccountViewModel.currencySymbolOptions
        #expect(options.contains("$"))
        #expect(options.contains("€"))
        #expect(options.contains("£"))
    }
}
