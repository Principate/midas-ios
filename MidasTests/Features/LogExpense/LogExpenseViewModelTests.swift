//
//  LogExpenseViewModelTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct LogExpenseViewModelTests {

    // MARK: - Helpers

    private func makeViewModel(
        accountRepo: MockAccountRepository = MockAccountRepository(),
        expenseRepo: MockExpenseRepository = MockExpenseRepository()
    ) -> LogExpenseViewModel {
        LogExpenseViewModel(
            accountRepository: accountRepo,
            expenseRepository: expenseRepo
        )
    }

    private func accountRepoWithAccounts() -> MockAccountRepository {
        let repo = MockAccountRepository()
        repo.accounts = [
            Account(
                name: "Primary Checking",
                currency: "USD",
                initialBalance: 5000,
                accountType: .checking,
                info: .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
            ),
        ]
        return repo
    }

    // MARK: - Initial State

    @Test func test_init_shouldHaveEmptyInputText() {
        let vm = makeViewModel()
        #expect(vm.inputText.isEmpty)
    }

    @Test func test_init_shouldNotBeSaving() {
        let vm = makeViewModel()
        #expect(!vm.isSaving)
    }

    @Test func test_init_shouldNotHaveSaved() {
        let vm = makeViewModel()
        #expect(!vm.didSave)
    }

    @Test func test_init_canSaveShouldBeFalse() {
        let vm = makeViewModel()
        #expect(!vm.canSave)
    }

    // MARK: - Parse Input

    @Test func test_parseInput_shouldUpdateParsedAmount() {
        let vm = makeViewModel()
        vm.inputText = "$150"
        #expect(vm.parsedInput.amount == 150.0)
    }

    @Test func test_parseInput_shouldMatchAccount() {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "from checking"
        #expect(vm.effectiveAccount?.name == "Primary Checking")
    }

    @Test func test_parseInput_shouldMatchCategory() {
        let vm = makeViewModel()
        vm.inputText = "for groceries"
        #expect(vm.effectiveCategory?.name == "Groceries")
    }

    @Test func test_parseInput_shouldExtractTags() {
        let vm = makeViewModel()
        vm.inputText = "#monthly #food"
        #expect(vm.tags.contains("monthly"))
        #expect(vm.tags.contains("food"))
    }

    // MARK: - Effective Values

    @Test func test_effectiveAmount_prefersEditedOverParsed() {
        let vm = makeViewModel()
        vm.inputText = "$100"
        vm.editedAmount = 200.0
        #expect(vm.effectiveAmount == 200.0)
    }

    @Test func test_effectiveAccount_prefersSelectedOverParsed() {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        let manualAccount = Account(
            name: "Manual",
            currency: "EUR",
            initialBalance: 0,
            accountType: .savings,
            info: .savings(minimumAmount: 0, interestRate: 0)
        )
        vm.inputText = "from checking"
        vm.selectedAccount = manualAccount
        #expect(vm.effectiveAccount?.name == "Manual")
    }

    @Test func test_effectiveCategory_prefersSelectedOverParsed() {
        let vm = makeViewModel()
        let manualCategory = ExpenseCategory(name: "Custom", color: "#FF0000")
        vm.inputText = "for groceries"
        vm.selectedCategory = manualCategory
        #expect(vm.effectiveCategory?.name == "Custom")
    }

    @Test func test_effectiveCurrency_defaultsToAccountCurrency() {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "from checking"
        #expect(vm.effectiveCurrency == "USD")
    }

    @Test func test_effectiveCurrency_prefersSelectedOverParsed() {
        let vm = makeViewModel()
        vm.selectedCurrency = "GBP"
        #expect(vm.effectiveCurrency == "GBP")
    }

    // MARK: - Validation

    @Test func test_canSave_whenAllFieldsPresent_shouldBeTrue() {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "$150 from checking for groceries"
        #expect(vm.canSave)
    }

    @Test func test_canSave_whenMissingAmount_shouldBeFalse() {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "from checking for groceries"
        #expect(!vm.canSave)
    }

    @Test func test_canSave_whenMissingAccount_shouldBeFalse() {
        let vm = makeViewModel()
        vm.inputText = "$150 for groceries"
        #expect(!vm.canSave)
    }

    @Test func test_canSave_whenMissingCategory_shouldBeFalse() {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "$150 from checking"
        #expect(!vm.canSave)
    }

    // MARK: - Tag Management

    @Test func test_addTag_shouldAppendTag() {
        let vm = makeViewModel()
        vm.addTag("monthly")
        #expect(vm.tags.contains("monthly"))
    }

    @Test func test_addTag_shouldStripHashPrefix() {
        let vm = makeViewModel()
        vm.addTag("#monthly")
        #expect(vm.tags.contains("monthly"))
    }

    @Test func test_addTag_shouldNotAddDuplicate() {
        let vm = makeViewModel()
        vm.addTag("monthly")
        vm.addTag("monthly")
        #expect(vm.tags.filter { $0 == "monthly" }.count == 1)
    }

    @Test func test_addTag_shouldNotAddEmpty() {
        let vm = makeViewModel()
        vm.addTag("")
        #expect(vm.tags.isEmpty)
    }

    @Test func test_removeTag_shouldRemoveTag() {
        let vm = makeViewModel()
        vm.addTag("monthly")
        vm.removeTag("monthly")
        #expect(!vm.tags.contains("monthly"))
    }

    @Test func test_parsedTags_shouldNotAccumulateIntermediateValues() {
        let vm = makeViewModel()
        vm.inputText = "#G"
        vm.inputText = "#Gr"
        vm.inputText = "#Gro"
        vm.inputText = "#Groceries"
        #expect(vm.tags == ["Groceries"])
    }

    @Test func test_parsedTags_whenTagRemovedFromInput_shouldDisappear() {
        let vm = makeViewModel()
        vm.inputText = "#monthly #food"
        #expect(vm.tags.contains("monthly"))
        #expect(vm.tags.contains("food"))
        vm.inputText = "#monthly"
        #expect(vm.tags == ["monthly"])
    }

    @Test func test_manualTags_shouldPersistAcrossReparses() {
        let vm = makeViewModel()
        vm.addTag("manual")
        vm.inputText = "#parsed"
        #expect(vm.tags.contains("manual"))
        #expect(vm.tags.contains("parsed"))
    }

    // MARK: - Category Creation

    @Test func test_createCategory_shouldAddToRepository() async {
        let expenseRepo = MockExpenseRepository()
        let vm = makeViewModel(expenseRepo: expenseRepo)
        vm.newCategoryName = "Pets"
        await vm.createCategory()
        #expect(expenseRepo.addCategoryCallCount == 1)
    }

    @Test func test_createCategory_shouldSelectNewCategory() async {
        let vm = makeViewModel()
        vm.newCategoryName = "Pets"
        await vm.createCategory()
        #expect(vm.selectedCategory?.name == "Pets")
    }

    @Test func test_createCategory_shouldClearNewCategoryName() async {
        let vm = makeViewModel()
        vm.newCategoryName = "Pets"
        await vm.createCategory()
        #expect(vm.newCategoryName.isEmpty)
    }

    @Test func test_createCategory_whenNameIsEmpty_shouldNotAdd() async {
        let expenseRepo = MockExpenseRepository()
        let vm = makeViewModel(expenseRepo: expenseRepo)
        vm.newCategoryName = "  "
        await vm.createCategory()
        #expect(expenseRepo.addCategoryCallCount == 0)
    }

    // MARK: - Save Expense

    @Test func test_saveExpense_whenValid_shouldAddToRepository() async {
        let accountRepo = accountRepoWithAccounts()
        let expenseRepo = MockExpenseRepository()
        let vm = makeViewModel(accountRepo: accountRepo, expenseRepo: expenseRepo)
        vm.inputText = "$150 from checking for groceries"
        await vm.saveExpense()
        #expect(expenseRepo.addExpenseCallCount == 1)
    }

    @Test func test_saveExpense_whenValid_shouldSetDidSave() async {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "$150 from checking for groceries"
        await vm.saveExpense()
        #expect(vm.didSave)
    }

    @Test func test_saveExpense_whenValid_shouldSetIsSavingFalse() async {
        let accountRepo = accountRepoWithAccounts()
        let vm = makeViewModel(accountRepo: accountRepo)
        vm.inputText = "$150 from checking for groceries"
        await vm.saveExpense()
        #expect(!vm.isSaving)
    }

    @Test func test_saveExpense_whenInvalid_shouldNotCallRepository() async {
        let expenseRepo = MockExpenseRepository()
        let vm = makeViewModel(expenseRepo: expenseRepo)
        vm.inputText = "just some text"
        await vm.saveExpense()
        #expect(expenseRepo.addExpenseCallCount == 0)
    }

    @Test func test_saveExpense_whenInvalid_shouldNotSetDidSave() async {
        let vm = makeViewModel()
        vm.inputText = "just some text"
        await vm.saveExpense()
        #expect(!vm.didSave)
    }

    @Test func test_saveExpense_whenRepositoryThrows_shouldSetSaveError() async {
        let accountRepo = accountRepoWithAccounts()
        let expenseRepo = MockExpenseRepository()
        expenseRepo.shouldThrowOnAdd = true
        let vm = makeViewModel(accountRepo: accountRepo, expenseRepo: expenseRepo)
        vm.inputText = "$150 from checking for groceries"
        await vm.saveExpense()
        #expect(vm.saveError != nil)
        #expect(!vm.didSave)
    }

    @Test func test_saveExpense_shouldPreserveTags() async {
        let accountRepo = accountRepoWithAccounts()
        let expenseRepo = MockExpenseRepository()
        let vm = makeViewModel(accountRepo: accountRepo, expenseRepo: expenseRepo)
        vm.inputText = "$150 from checking for groceries #monthly"
        await vm.saveExpense()
        #expect(expenseRepo.expenses.first?.tags.contains("monthly") == true)
    }

    // MARK: - Formatted Amount

    @Test func test_formattedAmount_shouldFormatWithTwoDecimals() {
        let vm = makeViewModel()
        vm.inputText = "$150"
        #expect(vm.formattedAmount == "150.00")
    }

    @Test func test_formattedAmount_whenNoAmount_shouldBeEmpty() {
        let vm = makeViewModel()
        #expect(vm.formattedAmount.isEmpty)
    }
}
