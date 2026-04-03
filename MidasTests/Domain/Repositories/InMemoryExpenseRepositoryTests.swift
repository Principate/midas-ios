//
//  InMemoryExpenseRepositoryTests.swift
//  MidasTests
//

import Testing
@testable import Midas

@MainActor
struct InMemoryExpenseRepositoryTests {

    @Test func test_init_shouldHaveEmptyExpenses() {
        let repository = InMemoryExpenseRepository()
        #expect(repository.expenses.isEmpty)
    }

    @Test func test_init_shouldHaveEmptyCategories() {
        let repository = InMemoryExpenseRepository()
        #expect(repository.categories.isEmpty)
    }

    @Test func test_addExpense_shouldAppendToExpenses() async throws {
        let repository = InMemoryExpenseRepository()
        let expense = Expense(
            amount: 150.0,
            currency: "USD",
            accountId: UUID(),
            categoryId: "cat-1"
        )
        try await repository.addExpense(expense)
        #expect(repository.expenses.count == 1)
    }

    @Test func test_addExpense_shouldPreserveExpenseData() async throws {
        let repository = InMemoryExpenseRepository()
        let accountId = UUID()
        let categoryId = "cat-1"
        let expense = Expense(
            amount: 42.50,
            currency: "EUR",
            accountId: accountId,
            categoryId: categoryId,
            title: "Coffee",
            tags: ["daily"]
        )
        try await repository.addExpense(expense)

        let stored = repository.expenses.first
        #expect(stored?.amount == 42.50)
        #expect(stored?.currency == "EUR")
        #expect(stored?.accountId == accountId)
        #expect(stored?.categoryId == categoryId)
        #expect(stored?.title == "Coffee")
        #expect(stored?.tags == ["daily"])
    }

    @Test func test_addCategory_shouldAppendToCategories() async throws {
        let repository = InMemoryExpenseRepository()
        let initialCount = repository.categories.count
        let category = ExpenseCategory(name: "Pets", color: "#8B4513")
        try await repository.addCategory(category)
        #expect(repository.categories.count == initialCount + 1)
    }

    @Test func test_addCategory_shouldPreserveCategoryData() async throws {
        let repository = InMemoryExpenseRepository()
        let category = ExpenseCategory(name: "Pets", color: "#8B4513")
        try await repository.addCategory(category)

        let stored = repository.categories.last
        #expect(stored?.name == "Pets")
        #expect(stored?.color == "#8B4513")
    }
}
