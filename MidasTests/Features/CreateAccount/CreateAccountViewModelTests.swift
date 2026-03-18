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

    @Test func test_init_shouldDefaultToDollarCurrency() {
        let vm = makeViewModel()
        #expect(vm.currencySymbol == "$")
    }

    @Test func test_init_shouldDefaultToBankIcon() {
        let vm = makeViewModel()
        #expect(vm.iconType == .bank)
    }

    @Test func test_init_didSaveShouldBeFalse() {
        let vm = makeViewModel()
        #expect(!vm.didSave)
    }

    @Test func test_init_shouldHaveEmptyBalanceString() {
        let vm = makeViewModel()
        #expect(vm.balanceString.isEmpty)
    }

    @Test func test_init_shouldHaveEmptyCreditLimitString() {
        let vm = makeViewModel()
        #expect(vm.creditLimitString.isEmpty)
    }

    @Test func test_init_shouldHaveNoMinimumBalanceRequirement() {
        let vm = makeViewModel()
        #expect(!vm.hasMinimumBalanceRequirement)
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

    // MARK: - Step 2 Validation (Credit Card)

    @Test func test_isStep2Valid_whenCreditCard_andCreditLimitIsEmpty_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = ""
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenCreditCard_andCreditLimitIsZero_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = "0"
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenCreditCard_andCreditLimitIsNegative_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = "-500"
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenCreditCard_andCreditLimitIsNotNumeric_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = "abc"
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenCreditCard_andCreditLimitIsPositive_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .creditCard
        vm.creditLimitString = "5000"
        #expect(vm.isStep2Valid)
    }

    // MARK: - Step 2 Validation (Savings)

    @Test func test_isStep2Valid_whenSavings_noMinimumBalance_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .savings
        vm.hasMinimumBalanceRequirement = false
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenSavings_withMinimumBalance_andValidAmount_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .savings
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "2500"
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenSavings_withMinimumBalance_andInvalidAmount_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .savings
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "abc"
        #expect(!vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenSavings_withMinimumBalance_andNegativeAmount_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .savings
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "-100"
        #expect(!vm.isStep2Valid)
    }

    // MARK: - Step 2 Validation (Checking)

    @Test func test_isStep2Valid_whenChecking_noMinimumBalance_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .checking
        vm.hasMinimumBalanceRequirement = false
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenChecking_withMinimumBalance_andValidAmount_shouldBeTrue() {
        let vm = makeViewModel()
        vm.accountType = .checking
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "1000"
        #expect(vm.isStep2Valid)
    }

    @Test func test_isStep2Valid_whenChecking_withMinimumBalance_andInvalidAmount_shouldBeFalse() {
        let vm = makeViewModel()
        vm.accountType = .checking
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "not a number"
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

    @Test func test_isCurrentStepValid_whenOnStep2_shouldUseStep2Validation() {
        let vm = makeViewModel()
        vm.currentStep = .accountSpecifics
        vm.accountType = .creditCard
        vm.creditLimitString = ""
        #expect(!vm.isCurrentStepValid)
        vm.creditLimitString = "5000"
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

    @Test func test_parsedCreditLimit_whenValid_shouldReturnDouble() {
        let vm = makeViewModel()
        vm.creditLimitString = "5000"
        #expect(vm.parsedCreditLimit == 5000)
    }

    @Test func test_parsedMinimumBalance_whenValid_shouldReturnDouble() {
        let vm = makeViewModel()
        vm.minimumBalanceString = "2500"
        #expect(vm.parsedMinimumBalance == 2500)
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
        vm.accountType = .checking
        vm.hasMinimumBalanceRequirement = false
        vm.goToNextStep()
        #expect(vm.currentStep == .finalize)
    }

    @Test func test_goToNextStep_fromStep2_whenInvalid_shouldStayOnStep2() {
        let vm = makeViewModel()
        vm.currentStep = .accountSpecifics
        vm.accountType = .creditCard
        vm.creditLimitString = ""
        vm.goToNextStep()
        #expect(vm.currentStep == .accountSpecifics)
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

    // MARK: - Save Account (Checking)

    @Test func test_saveAccount_withChecking_shouldCallRepository() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Checking"
        vm.accountType = .checking
        vm.currencySymbol = "$"
        vm.balanceString = "1000"
        vm.saveAccount()
        #expect(repo.addAccountCallCount == 1)
    }

    @Test func test_saveAccount_withChecking_shouldCreateAccountWithCorrectType() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Checking"
        vm.accountType = .checking
        vm.balanceString = "1000"
        vm.saveAccount()
        #expect(repo.lastAddedAccount?.accountType == .checking)
    }

    @Test func test_saveAccount_withChecking_shouldCreateAccountWithCorrectName() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Checking"
        vm.accountType = .checking
        vm.balanceString = "1000"
        vm.saveAccount()
        #expect(repo.lastAddedAccount?.name == "My Checking")
    }

    @Test func test_saveAccount_shouldTrimWhitespaceFromName() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "  My Checking  "
        vm.accountType = .checking
        vm.balanceString = "1000"
        vm.saveAccount()
        #expect(repo.lastAddedAccount?.name == "My Checking")
    }

    @Test func test_saveAccount_shouldSetDidSaveToTrue() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "0"
        vm.saveAccount()
        #expect(vm.didSave)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectBalance() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "5000.75"
        vm.saveAccount()
        #expect(repo.lastAddedAccount?.balance == 5000.75)
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectCurrency() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Euro Fund"
        vm.accountType = .savings
        vm.currencySymbol = "€"
        vm.balanceString = "3000"
        vm.saveAccount()
        #expect(repo.lastAddedAccount?.currencySymbol == "€")
    }

    @Test func test_saveAccount_shouldCreateAccountWithCorrectIcon() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Euro Fund"
        vm.accountType = .savings
        vm.balanceString = "3000"
        vm.iconType = .euro
        vm.saveAccount()
        #expect(repo.lastAddedAccount?.iconType == .euro)
    }

    // MARK: - Save Account (Credit Card with Type Details)

    @Test func test_saveAccount_withCreditCard_shouldIncludeCreditLimit() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Card"
        vm.accountType = .creditCard
        vm.creditLimitString = "5000"
        vm.balanceString = "0"
        vm.saveAccount()

        if case .creditCard(let limit, _, _) = repo.lastAddedAccount?.typeDetails {
            #expect(limit == 5000)
        } else {
            Issue.record("Expected creditCard type details")
        }
    }

    @Test func test_saveAccount_withCreditCard_shouldIncludeDates() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "My Card"
        vm.accountType = .creditCard
        vm.creditLimitString = "5000"
        vm.balanceString = "0"

        let closeDate = Date(timeIntervalSince1970: 1_000_000)
        let dueDate = Date(timeIntervalSince1970: 2_000_000)
        vm.statementCloseDate = closeDate
        vm.paymentDueDate = dueDate
        vm.saveAccount()

        if case .creditCard(_, let storedClose, let storedDue) = repo.lastAddedAccount?.typeDetails {
            #expect(storedClose == closeDate)
            #expect(storedDue == dueDate)
        } else {
            Issue.record("Expected creditCard type details")
        }
    }

    // MARK: - Save Account (Savings with Type Details)

    @Test func test_saveAccount_withSavings_andMinBalance_shouldIncludeMinBalance() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Savings"
        vm.accountType = .savings
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "2500"
        vm.balanceString = "5000"
        vm.saveAccount()

        if case .savings(let minBal) = repo.lastAddedAccount?.typeDetails {
            #expect(minBal == 2500)
        } else {
            Issue.record("Expected savings type details")
        }
    }

    @Test func test_saveAccount_withSavings_andNoMinBalance_shouldHaveNilMinBalance() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Savings"
        vm.accountType = .savings
        vm.hasMinimumBalanceRequirement = false
        vm.balanceString = "5000"
        vm.saveAccount()

        if case .savings(let minBal) = repo.lastAddedAccount?.typeDetails {
            #expect(minBal == nil)
        } else {
            Issue.record("Expected savings type details")
        }
    }

    // MARK: - Save Account (Checking with Type Details)

    @Test func test_saveAccount_withChecking_andMinBalance_shouldIncludeMinBalance() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Checking"
        vm.accountType = .checking
        vm.hasMinimumBalanceRequirement = true
        vm.minimumBalanceString = "1000"
        vm.balanceString = "5000"
        vm.saveAccount()

        if case .checking(let minBal) = repo.lastAddedAccount?.typeDetails {
            #expect(minBal == 1000)
        } else {
            Issue.record("Expected checking type details")
        }
    }

    @Test func test_saveAccount_withChecking_andNoMinBalance_shouldHaveNilMinBalance() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Checking"
        vm.accountType = .checking
        vm.hasMinimumBalanceRequirement = false
        vm.balanceString = "5000"
        vm.saveAccount()

        if case .checking(let minBal) = repo.lastAddedAccount?.typeDetails {
            #expect(minBal == nil)
        } else {
            Issue.record("Expected checking type details")
        }
    }

    // MARK: - Save Account (Invalid State)

    @Test func test_saveAccount_whenNameIsEmpty_shouldNotCallRepository() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = ""
        vm.balanceString = "1000"
        vm.saveAccount()
        #expect(repo.addAccountCallCount == 0)
        #expect(!vm.didSave)
    }

    @Test func test_saveAccount_whenBalanceIsInvalid_shouldNotCallRepository() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Test"
        vm.accountType = .checking
        vm.balanceString = "abc"
        vm.saveAccount()
        #expect(repo.addAccountCallCount == 0)
        #expect(!vm.didSave)
    }

    @Test func test_saveAccount_whenCreditCard_andLimitInvalid_shouldNotCallRepository() {
        let repo = MockAccountRepository()
        let vm = makeViewModel(repository: repo)
        vm.name = "Card"
        vm.accountType = .creditCard
        vm.creditLimitString = ""
        vm.balanceString = "0"
        vm.saveAccount()
        #expect(repo.addAccountCallCount == 0)
        #expect(!vm.didSave)
    }

    // MARK: - Currency Display

    @Test func test_currencyDisplayString_whenDollar_shouldReturnUSDFormatted() {
        let vm = makeViewModel()
        vm.currencySymbol = "$"
        #expect(vm.currencyDisplayString == "USD ($)")
    }

    @Test func test_currencyDisplayString_whenEuro_shouldReturnEURFormatted() {
        let vm = makeViewModel()
        vm.currencySymbol = "€"
        #expect(vm.currencyDisplayString == "EUR (€)")
    }

    @Test func test_currencyDisplayString_whenPound_shouldReturnGBPFormatted() {
        let vm = makeViewModel()
        vm.currencySymbol = "£"
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
}
