//
//  LogExpenseViewModel.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class LogExpenseViewModel {

    // MARK: - Dependencies

    private let accountRepository: AccountRepositoryProtocol
    private let expenseRepository: ExpenseRepositoryProtocol
    private let parser = ExpenseInputParser()

    // MARK: - Input State

    var inputText: String = "" {
        didSet { reparse() }
    }

    // MARK: - Parsed State (read-only outside)

    private(set) var parsedInput: ParsedExpenseInput = .empty

    // MARK: - Manual Overrides

    var editedAmount: Double?
    var selectedAccount: Account?
    var selectedCategory: ExpenseCategory?
    var selectedCurrency: String?

    // MARK: - Tag Management

    private(set) var tags: [String] = []
    private var manualTags: [String] = []

    // MARK: - Category Creation

    var newCategoryName: String = ""

    // MARK: - Save State

    private(set) var isSaving = false
    private(set) var didSave = false
    var saveError: String?

    // MARK: - Styling

    var styledText: AttributedString = AttributedString("")

    // MARK: - Init

    init(
        accountRepository: AccountRepositoryProtocol,
        expenseRepository: ExpenseRepositoryProtocol
    ) {
        self.accountRepository = accountRepository
        self.expenseRepository = expenseRepository
    }

    // MARK: - Effective Values

    var effectiveAmount: Double? {
        editedAmount ?? parsedInput.amount
    }

    var effectiveAccount: Account? {
        selectedAccount ?? parsedInput.matchedAccount
    }

    var effectiveCategory: ExpenseCategory? {
        selectedCategory ?? parsedInput.matchedCategory
    }

    var effectiveCurrency: String? {
        selectedCurrency ?? parsedInput.currencyCode ?? effectiveAccount?.currency
    }

    // MARK: - Validation

    var canSave: Bool {
        effectiveAmount != nil && effectiveAccount != nil && effectiveCategory != nil
    }

    // MARK: - Formatted Amount

    var formattedAmount: String {
        guard let amount = effectiveAmount else { return "" }
        return String(format: "%.2f", amount)
    }

    // MARK: - Parsing

    private func reparse() {
        parsedInput = parser.parse(
            inputText,
            accounts: accountRepository.accounts,
            categories: defaultCategories + expenseRepository.categories
        )

        // Rebuild tags: manual tags first, then parsed tags (no stale accumulation)
        var merged = manualTags
        for tag in parsedInput.tags {
            if !merged.contains(tag) {
                merged.append(tag)
            }
        }
        tags = merged

        updateStyledText()
    }

    private func updateStyledText() {
        var styled = AttributedString(inputText)

        styled = parser.applyStyling(
            to: styled,
            accounts: accountRepository.accounts,
            categories: defaultCategories + expenseRepository.categories
        )

        styledText = styled
    }

    // MARK: - Default Categories

    private var defaultCategories: [ExpenseCategory] {
        [
            ExpenseCategory(name: "Groceries", color: "#4CAF50"),
            ExpenseCategory(name: "Dining", color: "#FF9800"),
            ExpenseCategory(name: "Transport", color: "#2196F3"),
            ExpenseCategory(name: "Shopping", color: "#E91E63"),
            ExpenseCategory(name: "Entertainment", color: "#9C27B0"),
            ExpenseCategory(name: "Bills & Utilities", color: "#607D8B"),
            ExpenseCategory(name: "Health", color: "#F44336"),
            ExpenseCategory(name: "Travel", color: "#00BCD4"),
        ]
    }

    // MARK: - Tag Management

    func addTag(_ raw: String) {
        let tag = raw.hasPrefix("#") ? String(raw.dropFirst()) : raw
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        manualTags.append(trimmed)
        tags.append(trimmed)
    }

    func removeTag(_ tag: String) {
        manualTags.removeAll { $0 == tag }
        tags.removeAll { $0 == tag }
    }

    // MARK: - Category Creation

    func createCategory() async {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let category = ExpenseCategory(name: trimmed)
        try? await expenseRepository.addCategory(category)
        selectedCategory = category
        newCategoryName = ""
    }

    // MARK: - Save Expense

    func saveExpense() async {
        guard canSave,
              let amount = effectiveAmount,
              let account = effectiveAccount,
              let category = effectiveCategory else {
            return
        }

        isSaving = true
        saveError = nil

        let expense = Expense(
            amount: amount,
            currency: effectiveCurrency ?? account.currency,
            accountId: account.id,
            categoryId: category.id,
            title: parsedInput.title,
            tags: tags,
            date: Date()
        )

        do {
            try await expenseRepository.addExpense(expense)
            didSave = true
        } catch {
            saveError = error.localizedDescription
        }

        isSaving = false
    }
}
