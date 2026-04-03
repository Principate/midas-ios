//
//  ExpenseInputParserTests.swift
//  MidasTests
//

import Testing
@testable import Midas

struct ExpenseInputParserTests {

    private let parser = ExpenseInputParser()

    private let sampleAccounts: [Account] = [
        Account(
            name: "Primary Checking",
            currency: "USD",
            initialBalance: 5000,
            accountType: .checking,
            info: .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
        ),
        Account(
            name: "European Vault",
            currency: "EUR",
            initialBalance: 10000,
            accountType: .savings,
            info: .savings(minimumAmount: 0, interestRate: 0)
        ),
    ]

    private let sampleCategories: [ExpenseCategory] = [
        ExpenseCategory(name: "Groceries", color: "#4CAF50"),
        ExpenseCategory(name: "Dining", color: "#FF9800"),
        ExpenseCategory(name: "Bills & Utilities", color: "#607D8B"),
    ]

    // MARK: - Empty Input

    @Test func test_parse_emptyInput_shouldReturnEmpty() {
        let result = parser.parse("", accounts: [], categories: [])
        #expect(result.amount == nil)
        #expect(result.currencyCode == nil)
        #expect(result.matchedAccount == nil)
        #expect(result.matchedCategory == nil)
        #expect(result.tags.isEmpty)
        #expect(result.title.isEmpty)
    }

    @Test func test_parse_whitespaceOnly_shouldReturnEmpty() {
        let result = parser.parse("   ", accounts: [], categories: [])
        #expect(result == .empty)
    }

    // MARK: - Amount Extraction

    @Test func test_parse_extractsAmountFromDollarSign() {
        let result = parser.parse("$150", accounts: [], categories: [])
        #expect(result.amount == 150.0)
    }

    @Test func test_parse_extractsAmountWithDecimals() {
        let result = parser.parse("$12.50", accounts: [], categories: [])
        #expect(result.amount == 12.5)
    }

    @Test func test_parse_extractsAmountWithCommas() {
        let result = parser.parse("$1,234.56", accounts: [], categories: [])
        #expect(result.amount == 1234.56)
    }

    @Test func test_parse_dollarAmountImpliesUSD() {
        let result = parser.parse("$150", accounts: [], categories: [])
        #expect(result.currencyCode == "USD")
    }

    @Test func test_parse_extractsAmountWithCurrencyCode() {
        let result = parser.parse("150 EUR", accounts: [], categories: [])
        #expect(result.amount == 150.0)
        #expect(result.currencyCode == "EUR")
    }

    @Test func test_parse_extractsAmountWithGBP() {
        let result = parser.parse("42.50 GBP", accounts: [], categories: [])
        #expect(result.amount == 42.5)
        #expect(result.currencyCode == "GBP")
    }

    @Test func test_parse_amountOnly_shouldHaveEmptyTitle() {
        let result = parser.parse("$50", accounts: [], categories: [])
        #expect(result.amount == 50.0)
        #expect(result.title.isEmpty)
    }

    // MARK: - Tag Extraction

    @Test func test_parse_extractsSingleTag() {
        let result = parser.parse("#monthly", accounts: [], categories: [])
        #expect(result.tags == ["monthly"])
    }

    @Test func test_parse_extractsMultipleTags() {
        let result = parser.parse("#monthly #food", accounts: [], categories: [])
        #expect(result.tags == ["monthly", "food"])
    }

    @Test func test_parse_tagsAreCaseSensitive() {
        let result = parser.parse("#Monthly", accounts: [], categories: [])
        #expect(result.tags == ["Monthly"])
    }

    // MARK: - Account Matching

    @Test func test_parse_matchesAccountByTypeName() {
        let result = parser.parse(
            "from checking",
            accounts: sampleAccounts,
            categories: []
        )
        #expect(result.matchedAccount?.name == "Primary Checking")
    }

    @Test func test_parse_matchesAccountByFullName() {
        let result = parser.parse(
            "from Primary Checking",
            accounts: sampleAccounts,
            categories: []
        )
        #expect(result.matchedAccount?.name == "Primary Checking")
    }

    @Test func test_parse_matchesAccountCaseInsensitive() {
        let result = parser.parse(
            "from CHECKING",
            accounts: sampleAccounts,
            categories: []
        )
        #expect(result.matchedAccount?.name == "Primary Checking")
    }

    @Test func test_parse_matchesSavingsAccount() {
        let result = parser.parse(
            "from savings",
            accounts: sampleAccounts,
            categories: []
        )
        #expect(result.matchedAccount?.name == "European Vault")
    }

    // MARK: - Category Matching

    @Test func test_parse_matchesCategoryByName() {
        let result = parser.parse(
            "for groceries",
            accounts: [],
            categories: sampleCategories
        )
        #expect(result.matchedCategory?.name == "Groceries")
    }

    @Test func test_parse_matchesCategoryCaseInsensitive() {
        let result = parser.parse(
            "for DINING",
            accounts: [],
            categories: sampleCategories
        )
        #expect(result.matchedCategory?.name == "Dining")
    }

    @Test func test_parse_matchesMultiWordCategory() {
        let result = parser.parse(
            "for bills & utilities",
            accounts: [],
            categories: sampleCategories
        )
        #expect(result.matchedCategory?.name == "Bills & Utilities")
    }

    // MARK: - Title Extraction

    @Test func test_parse_extractsTitleFromRemainingText() {
        let result = parser.parse(
            "Spent $150 at Whole Foods from checking for groceries",
            accounts: sampleAccounts,
            categories: sampleCategories
        )
        #expect(result.title == "Whole Foods")
    }

    @Test func test_parse_stripsFillersFromTitle() {
        let result = parser.parse(
            "Spent at the store",
            accounts: [],
            categories: []
        )
        #expect(result.title == "store")
    }

    // MARK: - Full Sentence Parsing

    @Test func test_parse_fullSentence_shouldExtractAllEntities() {
        let result = parser.parse(
            "Spent $150 at Whole Foods from checking for groceries #monthly",
            accounts: sampleAccounts,
            categories: sampleCategories
        )
        #expect(result.amount == 150.0)
        #expect(result.currencyCode == "USD")
        #expect(result.matchedAccount?.name == "Primary Checking")
        #expect(result.matchedCategory?.name == "Groceries")
        #expect(result.tags == ["monthly"])
        #expect(result.title == "Whole Foods")
    }

    @Test func test_parse_sentenceWithEurAmount() {
        let result = parser.parse(
            "150 EUR at bakery from savings for dining",
            accounts: sampleAccounts,
            categories: sampleCategories
        )
        #expect(result.amount == 150.0)
        #expect(result.currencyCode == "EUR")
        #expect(result.matchedAccount?.name == "European Vault")
        #expect(result.matchedCategory?.name == "Dining")
        #expect(result.title == "bakery")
    }

    @Test func test_parse_sentenceWithMultipleTags() {
        let result = parser.parse(
            "$25 coffee #daily #work",
            accounts: [],
            categories: []
        )
        #expect(result.amount == 25.0)
        #expect(result.tags == ["daily", "work"])
        #expect(result.title == "coffee")
    }

    // MARK: - No Matches

    @Test func test_parse_noAccountMatch_shouldReturnNilAccount() {
        let result = parser.parse(
            "$50 at store",
            accounts: sampleAccounts,
            categories: []
        )
        #expect(result.matchedAccount == nil)
    }

    @Test func test_parse_noCategoryMatch_shouldReturnNilCategory() {
        let result = parser.parse(
            "$50 at store",
            accounts: [],
            categories: sampleCategories
        )
        #expect(result.matchedCategory == nil)
    }
}
