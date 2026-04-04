//
//  LogExpenseViewModel.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class LogExpenseViewModel {

    // MARK: - Dependencies

    let accountRepository: AccountRepositoryProtocol
    private let expenseRepository: ExpenseRepositoryProtocol
    private let parser = ExpenseInputParser()

    // MARK: - Autocomplete Trigger

    enum AutocompleteTrigger {
        case account  // triggered by @
        case category // triggered by /
    }

    private(set) var activeTrigger: AutocompleteTrigger = .account
    private(set) var autocompleteQuery: String = ""
    private(set) var showAutocompleteSuggestions = false

    // Range in inputText that the trigger + query occupies (for replacement on selection)
    private var triggerRange: Range<String.Index>?

    // MARK: - Input State

    var inputText: String = "" {
        didSet {
            detectAutocompleteTrigger()
            reparse()
        }
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

    // MARK: - Available Options

    var availableAccounts: [Account] {
        accountRepository.accounts
    }

    var availableCategories: [ExpenseCategory] {
        defaultCategories + expenseRepository.categories
    }

    // MARK: - Autocomplete Filtering

    var filteredAccounts: [Account] {
        let accounts = availableAccounts
        if autocompleteQuery.isEmpty { return accounts }
        return accounts.filter { $0.name.localizedCaseInsensitiveContains(autocompleteQuery) }
    }

    var filteredCategories: [ExpenseCategory] {
        let categories = availableCategories
        if autocompleteQuery.isEmpty { return categories }
        return categories.filter { $0.name.localizedCaseInsensitiveContains(autocompleteQuery) }
    }

    // MARK: - Trigger Detection

    /// Scans inputText for the last `@` or `/` that looks like an active trigger
    /// (i.e. at start or preceded by a space, and not yet closed by a space after the query).
    private func detectAutocompleteTrigger() {
        // Look for the last occurrence of @ or / that is at start or preceded by whitespace
        let text = inputText

        var bestTrigger: AutocompleteTrigger?
        var bestStart: String.Index?
        var bestQueryStart: String.Index?

        for triggerChar: Character in ["@", "/"] {
            // Search backwards for the last occurrence
            if let lastIndex = text.lastIndex(of: triggerChar) {
                // Must be at the start or preceded by whitespace
                let isAtStart = lastIndex == text.startIndex
                let precededBySpace = !isAtStart && text[text.index(before: lastIndex)].isWhitespace

                guard isAtStart || precededBySpace else { continue }

                let queryStart = text.index(after: lastIndex)
                let querySubstring = text[queryStart...]

                // If the query contains a space, the trigger is "closed" — not active
                if querySubstring.contains(" ") { continue }

                // Pick the trigger that appears latest in the string
                if bestStart == nil || lastIndex > bestStart! {
                    bestTrigger = triggerChar == "@" ? .account : .category
                    bestStart = lastIndex
                    bestQueryStart = queryStart
                }
            }
        }

        if let trigger = bestTrigger, let start = bestStart, let qStart = bestQueryStart {
            activeTrigger = trigger
            autocompleteQuery = String(text[qStart...])
            triggerRange = start..<text.endIndex
            showAutocompleteSuggestions = true
        } else {
            showAutocompleteSuggestions = false
            autocompleteQuery = ""
            triggerRange = nil
        }
    }

    // MARK: - Autocomplete Selection

    func selectAccountFromAutocomplete(_ account: Account) {
        replaceAutocompleteToken(with: account.name)
        selectedAccount = account
    }

    func selectCategoryFromAutocomplete(_ category: ExpenseCategory) {
        replaceAutocompleteToken(with: category.name)
        selectedCategory = category
    }

    private func replaceAutocompleteToken(with name: String) {
        guard let range = triggerRange else { return }
        inputText.replaceSubrange(range, with: name)
        showAutocompleteSuggestions = false
        autocompleteQuery = ""
        triggerRange = nil
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
