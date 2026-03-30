//
//  CreateAccountViewModelTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct CreateAccountViewModelTests {

    // MARK: - Helpers

    private func makeViewModel(
        repository: MockAccountRepository = MockAccountRepository()
    ) -> CreateAccountViewModel {
        CreateAccountViewModel(accountRepository: repository)
    }

    // MARK: - Initial State

    @Test func test_init_shouldStartAtAccountInfoStep() {
        let vm = makeViewModel()
        #expect(vm.currentStep == .accountInfo)
    }

    @Test func test_init_shouldHaveEmptyName() {
        let vm = makeViewModel()
        #expect(vm.name.isEmpty)
    }

    @Test func test_init_shouldDefaultToCheckingType() {
        let vm = makeViewModel()
        #expect(vm.accountType == .checking)
    }

    @Test func test_init_shouldDefaultToUSDCurrency() {
        let vm = makeViewModel()
        #expect(vm.currency == "USD")
    }

    @Test func test_init_shouldDefaultToBankIcon() {
        let vm = makeViewModel()
        #expect(vm.icon == .bank)
    }

    @Test func test_init_shouldDefaultToBlackColor() {
        let vm = makeViewModel()
        #expect(vm.color == AccountColor.black.rawValue)
    }

    @Test func test_init_didSaveShouldBeFalse() {
        let vm = makeViewModel()
        #expect(!vm.didSave)
    }

    @Test func test_init_shouldHaveEmptyBalanceString() {
        let vm = makeViewModel()
        #expect(vm.balanceString.isEmpty)
    }

    // MARK: - Step 1 Validation

    @Test func test_isStep1Valid_whenNameIsEmpty_shouldBeFalse() {
        let vm = makeViewModel()
        vm.name = ""
        #expect(!vm.isStep1Valid)
    }

    @Test func test_isStep1Valid_whenNameIsWhitespace_shouldBeFalse() {
        let vm = makeViewModel()
        vm.name = "   "
        #expect(!vm.isStep1Valid)
    }

    @Test func test_isStep1Valid_whenNameIsPresent_shouldBeTrue() {
        let vm = makeViewModel()
        vm.name = "My Account"
        #expect(vm.isStep1Valid)
    }

    // MARK: - Step 2 Validation (Checking)

    @Test func test_isStep2Valid_checking_whenAllFieldsEmpty_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .checking
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_checking_whenOverdraftLimitIsInvalid_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .checking
        vm.overdraftLimitString = "xyz"
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_checking_whenMinimumAmountIsInvalid_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .checking
        vm.minimumAmountString = "abc"
        #expect(!vm.isStep2Valid)
    }

    // MARK: - Step 2 Validation (Credit Card)

    @Test func test_isStep2Valid_creditCard_whenAllFieldsValid_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = "5000"
        vm.dueDateString = "15"
        vm.closeDateString = "1"
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_creditCard_whenLimitMissing_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = ""
        vm.dueDateString = "15"
        vm.closeDateString = "1"
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_creditCard_whenDueDateOutOfRange_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = "5000"
        vm.dueDateString = "32"
        vm.closeDateString = "1"
        #expect(!vm.isStep2Valid)
    }

    // MARK: - Step 2 Validation (Savings)

    @Test func test_isStep2Valid_savings_whenAllFieldsEmpty_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .savings
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_savings_whenInterestRateIsInvalid_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .savings
        vm.interestRateString = "abc"
        #expect(!vm.isStep2Valid)
    }

    // MARK: - Step 3 Validation

    @Test func test_isStep3Valid_whenBalanceIsEmpty_shouldBeFalse() {
        let vm = makeViewModel()
        vm.balanceString = ""
        #expect(!vm.isStep3Valid)
    }

    @Test func test_isStep3Valid_whenBalanceIsNotNumeric_shouldBeFalse() {
        let vm = makeViewModel()
        vm.balanceString = "abc"
        #expect(!vm.isStep3Valid)
    }

    @Test func test_isStep3Valid_whenBalanceIsNegative_shouldBeFalse() {
        let vm = makeViewModel()
        vm.balanceString = "-100"
        #expect(!vm.isStep3Valid)
    }

    @Test func test_isStep3Valid_whenBalanceIsZero_shouldBeTrue() {
        let vm = makeViewModel()
        vm.balanceString = "0"
        #expect(vm.isStep3Valid)
    }

    @Test func test_isStep3Valid_whenBalanceIsPositive_shouldBeTrue() {
        let vm = makeViewModel()
        vm.balanceString = "5000.50"
        #expect(vm.isStep3Valid)
    }

    // MARK: - Current Step Validation

    @Test func test_isCurrentStepValid_whenOnStep1_shouldUseStep1Validation() {
        let vm = makeViewModel()
        vm.currentStep = .accountInfo
        vm.name = ""
        #expect(!vm.isCurrentStepValid)
        vm.name = "Test"
        #expect(vm.isCurrentStepValid)
    }

    @Test func test_isCurrentStepValid_whenOnStep3_shouldUseStep3Validation() {
        let vm = makeViewModel()
        vm.currentStep = .finalize
        vm.balanceString = ""
        #expect(!vm.isCurrentStepValid)
        vm.balanceString = "1000"
        #expect(vm.isCurrentStepValid)
    }

    // MARK: - Parsed Values

    @Test func test_parsedBalance_whenBalanceStringIsValid_shouldReturnDouble() {
        let vm = makeViewModel()
        vm.balanceString = "1234.56"
        #expect(vm.parsedBalance == 1234.56)
    }

    @Test func test_parsedBalance_whenBalanceStringIsEmpty_shouldReturnNil() {
        let vm = makeViewModel()
        vm.balanceString = ""
        #expect(vm.parsedBalance == nil)
    }

    @Test func test_parsedBalance_whenBalanceStringIsNotNumeric_shouldReturnNil() {
        let vm = makeViewModel()
        vm.balanceString = "not a number"
        #expect(vm.parsedBalance == nil)
    }

    // MARK: - Navigation

    @Test func test_goToNextStep_fromStep1_whenValid_shouldAdvanceToStep2() {
        let vm = makeViewModel()
        vm.name = "Test Account"
        vm.goToNextStep()
        #expect(vm.currentStep == .accountSpecifics)
    }

    @Test func test_goToNextStep_fromStep1_whenInvalid_shouldStayOnStep1() {
        let vm = makeViewModel()
        vm.name = ""
        vm.goToNextStep()
        #expect(vm.currentStep == .accountInfo)
    }

    @Test func test_goToNextStep_fromStep2_whenValid_shouldAdvanceToStep3() {
        let vm = makeViewModel()
        vm.currentStep = .accountSpecifics
        vm.goToNextStep()
        #expect(vm.currentStep == .finalize)
    }

    @Test func test_goToNextStep_fromStep3_shouldNotAdvance() {
        let vm = makeViewModel()
        vm.currentStep = .finalize
        vm.balanceString = "1000"
        vm.goToNextStep()
        #expect(vm.currentStep == .finalize)
    }

    @Test func test_goToPreviousStep_fromStep2_shouldReturnToStep1() {
        let vm = makeViewModel()
        vm.currentStep = .accountSpecifics
        vm.goToPreviousStep()
        #expect(vm.currentStep == .accountInfo)
    }

    @Test func test_goToPreviousStep_fromStep3_shouldReturnToStep2() {
        let vm = makeViewModel()
        vm.currentStep = .finalize
        vm.goToPreviousStep()
        #expect(vm.currentStep == .accountSpecifics)
    }

    @Test func test_goToPreviousStep_fromStep1_shouldStayOnStep1() {
        let vm = makeViewModel()
        vm.currentStep = .accountInfo
        vm.goToPreviousStep()
        #expect(vm.currentStep == .accountInfo)
    }

    // MARK: - Save Account (Basic)

    @Test func test_saveAccount_shouldCallRepository() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Checking"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(repo.addAccountCallCount == 1)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectType() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Checking"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.accountType == .checking)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectName() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Checking"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.name == "My Checking")
    }

    @Test func test_saveAccount_shouldTrimWhitespaceFromName() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "  My Checking  "
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.name == "My Checking")
    }

    @Test func test_saveAccount_shouldSetDidSaveToTrue() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "0"
        await vm.saveAccount()
        #expect(vm.didSave)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectBalance() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "5000.75"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.initialBalance == 5000.75)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectCurrency() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Euro Fund"
        vm.accountType = .savings
        vm.currency = "EUR"
        vm.balanceString = "3000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.currency == "EUR")
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectIcon() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Euro Fund"
        vm.accountType = .savings
        vm.balanceString = "3000"
        vm.icon = .euro
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.icon == AccountIcon.euro.rawValue)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectColor() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "1000"
        vm.color = AccountColor.navy.rawValue
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.color == "#1B2A4A")
    }

    // MARK: - Save Account (Info Variants)

    @Test func test_saveAccount_checking_shouldBuildCheckingInfo() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Checking"
        vm.accountType = .checking
        vm.minimumAmountString = "500"
        vm.interestRateString = "1.5"
        vm.overdraftLimitString = "200"
        vm.balanceString = "5000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.info == .checking(minimumAmount: 500, interestRate: 1.5, overdraftLimit: 200))
    }

    @Test func test_saveAccount_savings_shouldBuildSavingsInfo() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Savings"
        vm.accountType = .savings
        vm.minimumAmountString = "1000"
        vm.interestRateString = "2.5"
        vm.balanceString = "5000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.info == .savings(minimumAmount: 1000, interestRate: 2.5))
    }

    @Test func test_saveAccount_creditCard_shouldBuildCreditCardInfo() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Visa"
        vm.accountType = .creditCard
        vm.creditLimitString = "10000"
        vm.dueDateString = "15"
        vm.closeDateString = "1"
        vm.balanceString = "3000"
        await vm.saveAccount()
        #expect(repo.lastAddedAccount?.info == .creditCard(limit: 10000, dueDate: 15, closeDate: 1))
    }

    @Test func test_saveAccount_changingType_shouldResetSpecificsFields() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.overdraftLimitString = "500"
        // Change to savings — overdraft should be cleared
        vm.accountType = .savings
        #expect(vm.overdraftLimitString.isEmpty)
        #expect(vm.creditLimitString.isEmpty)
    }

    // MARK: - Save Account (Invalid State)

    @Test func test_saveAccount_whenNameIsEmpty_shouldNotCallRepository() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = ""
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(repo.addAccountCallCount == 0)
        #expect(!vm.didSave)
    }

    @Test func test_saveAccount_whenBalanceIsInvalid_shouldNotCallRepository() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "abc"
        await vm.saveAccount()
        #expect(repo.addAccountCallCount == 0)
        #expect(!vm.didSave)
    }

    // MARK: - Currency Display

    @Test func test_currencyDisplayString_whenUSD_shouldReturnUSDFormatted() {
        let vm = makeViewModel()
        vm.currency = "USD"
        #expect(vm.currencyDisplayString == "USD ($)")
    }

    @Test func test_currencyDisplayString_whenEUR_shouldReturnEURFormatted() {
        let vm = makeViewModel()
        vm.currency = "EUR"
        #expect(vm.currencyDisplayString == "EUR (€)")
    }

    @Test func test_currencyDisplayString_whenGBP_shouldReturnGBPFormatted() {
        let vm = makeViewModel()
        vm.currency = "GBP"
        #expect(vm.currencyDisplayString == "GBP (£)")
    }

    // MARK: - Step Progress

    @Test func test_stepProgressPercentage_step1_shouldBe33() {
        let vm = makeViewModel()
        vm.currentStep = .accountInfo
        #expect(vm.currentStep.progressPercentage == 33)
    }

    @Test func test_stepProgressPercentage_step2_shouldBe66() {
        let vm = makeViewModel()
        vm.currentStep = .accountSpecifics
        #expect(vm.currentStep.progressPercentage == 66)
    }

    @Test func test_stepProgressPercentage_step3_shouldBe100() {
        let vm = makeViewModel()
        vm.currentStep = .finalize
        #expect(vm.currentStep.progressPercentage == 100)
    }

    // MARK: - Save Account (Error Handling)

    @Test func test_saveAccount_whenRepositoryThrows_shouldSetSaveError() async {
        let repo = MockAccountRepository()
        repo.addAccountError = NetworkError.httpError(statusCode: 500)
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(vm.saveError != nil)
        #expect(!vm.didSave)
    }

    @Test func test_saveAccount_whenRepositoryThrows_shouldNotSetDidSave() async {
        let repo = MockAccountRepository()
        repo.addAccountError = NetworkError.httpError(statusCode: 422)
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(!vm.didSave)
    }

    @Test func test_saveAccount_whenSuccessful_shouldClearSaveError() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(vm.saveError == nil)
    }

    @Test func test_saveAccount_shouldSetIsSavingFalseAfterCompletion() async {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(!vm.isSaving)
    }

    @Test func test_saveAccount_whenRepositoryThrows_shouldSetIsSavingFalseAfterError() async {
        let repo = MockAccountRepository()
        repo.addAccountError = NetworkError.httpError(statusCode: 500)
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "1000"
        await vm.saveAccount()
        #expect(!vm.isSaving)
    }
}
