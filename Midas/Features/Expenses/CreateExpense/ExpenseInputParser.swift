//
//  ExpenseInputParser.swift
//  Midas
//

import Foundation
import SwiftUI

struct ParsedExpenseInput: Equatable {
    var amount: Double?
    var currencyCode: String?
    var matchedAccount: Account?
    var matchedCategory: ExpenseCategory?
    var tags: [String]
    var title: String

    static let empty = ParsedExpenseInput(
        amount: nil,
        currencyCode: nil,
        matchedAccount: nil,
        matchedCategory: nil,
        tags: [],
        title: ""
    )
}

struct ExpenseInputParser {

    // MARK: - Public

    func parse(
        _ text: String,
        accounts: [Account],
        categories: [ExpenseCategory]
    ) -> ParsedExpenseInput {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        var remaining = trimmed

        // Extract amount and currency
        let (amount, currencyCode, remainingAfterAmount) = extractAmount(from: remaining)
        remaining = remainingAfterAmount

        // Extract tags
        let (tags, remainingAfterTags) = extractTags(from: remaining)
        remaining = remainingAfterTags

        // Match account
        let matchedAccount = matchAccount(in: trimmed, accounts: accounts)

        // Match category
        let matchedCategory = matchCategory(in: trimmed, categories: categories)

        // Extract title from remaining text
        let title = extractTitle(
            from: remaining,
            matchedAccount: matchedAccount,
            matchedCategory: matchedCategory
        )

        return ParsedExpenseInput(
            amount: amount,
            currencyCode: currencyCode,
            matchedAccount: matchedAccount,
            matchedCategory: matchedCategory,
            tags: tags,
            title: title
        )
    }

    // MARK: - Amount Extraction

    private func extractAmount(from text: String) -> (Double?, String?, String) {
        // Pattern 1: $amount (e.g. "$150", "$12.50", "$1,234.56")
        if let regex = try? NSRegularExpression(pattern: #"\$(\d[\d,]*(?:\.\d+)?)"#),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let valueRange = Range(match.range(at: 1), in: text) {
            let raw = String(text[valueRange]).replacingOccurrences(of: ",", with: "")
            if let value = Double(raw) {
                let fullRange = Range(match.range, in: text)!
                let remaining = text.replacingCharacters(in: fullRange, with: "")
                return (value, "USD", remaining)
            }
        }

        // Pattern 2: amount CURRENCY (e.g. "150 EUR", "42.50 GBP")
        if let regex = try? NSRegularExpression(pattern: #"(\d[\d,]*(?:\.\d+)?)\s+([A-Z]{3})"#),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let valueRange = Range(match.range(at: 1), in: text),
           let codeRange = Range(match.range(at: 2), in: text) {
            let raw = String(text[valueRange]).replacingOccurrences(of: ",", with: "")
            if let value = Double(raw) {
                let code = String(text[codeRange])
                let fullRange = Range(match.range, in: text)!
                let remaining = text.replacingCharacters(in: fullRange, with: "")
                return (value, code, remaining)
            }
        }

        return (nil, nil, text)
    }

    // MARK: - Tag Extraction

    private func extractTags(from text: String) -> ([String], String) {
        guard let regex = try? NSRegularExpression(pattern: #"#(\w+)"#) else {
            return ([], text)
        }

        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        var tags: [String] = []
        var seen = Set<String>()

        for match in matches {
            guard let range = Range(match.range(at: 1), in: text) else { continue }
            let tag = String(text[range])
            if seen.insert(tag).inserted {
                tags.append(tag)
            }
        }

        // Remove tag tokens from text
        var remaining = text
        if let fullRegex = try? NSRegularExpression(pattern: #"#\w+"#) {
            remaining = fullRegex.stringByReplacingMatches(
                in: remaining,
                range: NSRange(remaining.startIndex..., in: remaining),
                withTemplate: ""
            )
        }

        return (tags, remaining)
    }

    // MARK: - Account Matching

    private func matchAccount(in text: String, accounts: [Account]) -> Account? {
        let lowercased = text.lowercased()

        // Match by full account name (longer names first)
        let sortedByName = accounts.sorted { $0.name.count > $1.name.count }
        for account in sortedByName {
            if lowercased.contains(account.name.lowercased()) {
                return account
            }
        }

        // Match by account type keyword
        for account in accounts {
            let typeKeyword = account.accountType.displayName.lowercased()
            if lowercased.contains(typeKeyword) {
                return account
            }
        }

        return nil
    }

    // MARK: - Category Matching

    private func matchCategory(in text: String, categories: [ExpenseCategory]) -> ExpenseCategory? {
        let lowercased = text.lowercased()
        let sorted = categories.sorted { $0.name.count > $1.name.count }

        for category in sorted {
            if lowercased.contains(category.name.lowercased()) {
                return category
            }
        }

        return nil
    }

    // MARK: - Title Extraction

    private static let fillerWords: Set<String> = [
        "spent", "at", "the", "from", "for", "on", "to", "in", "a", "an", "my", "with"
    ]

    private func extractTitle(
        from remaining: String,
        matchedAccount: Account?,
        matchedCategory: ExpenseCategory?
    ) -> String {
        var text = remaining

        // Remove account name references
        if let accountName = matchedAccount?.name {
            if let regex = try? NSRegularExpression(
                pattern: NSRegularExpression.escapedPattern(for: accountName),
                options: .caseInsensitive
            ) {
                text = regex.stringByReplacingMatches(
                    in: text,
                    range: NSRange(text.startIndex..., in: text),
                    withTemplate: ""
                )
            }
            // Also remove account type keyword
            let typeKeyword = matchedAccount!.accountType.displayName
            if let regex = try? NSRegularExpression(
                pattern: NSRegularExpression.escapedPattern(for: typeKeyword),
                options: .caseInsensitive
            ) {
                text = regex.stringByReplacingMatches(
                    in: text,
                    range: NSRange(text.startIndex..., in: text),
                    withTemplate: ""
                )
            }
        }

        // Remove category name references
        if let categoryName = matchedCategory?.name {
            if let regex = try? NSRegularExpression(
                pattern: NSRegularExpression.escapedPattern(for: categoryName),
                options: .caseInsensitive
            ) {
                text = regex.stringByReplacingMatches(
                    in: text,
                    range: NSRange(text.startIndex..., in: text),
                    withTemplate: ""
                )
            }
        }

        // Tokenize and strip filler words
        let words = text
            .split(separator: " ")
            .map { String($0) }
            .filter { !Self.fillerWords.contains($0.lowercased()) }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        return words.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Styled Text

    func applyStyling(
        to input: AttributedString,
        accounts: [Account],
        categories: [ExpenseCategory]
    ) -> AttributedString {
        let plainText = String(input.characters)

        var result = input
        result.foregroundColor = nil
        result.backgroundColor = nil

        // Style amount tokens
        if let amountRegex = try? NSRegularExpression(
            pattern: #"\$\d[\d,]*(?:\.\d+)?|\d[\d,]*(?:\.\d+)?\s+[A-Z]{3}"#
        ) {
            for match in amountRegex.matches(in: plainText, range: NSRange(plainText.startIndex..., in: plainText)) {
                guard let range = Range(match.range, in: plainText) else { continue }
                let start = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.lowerBound))
                let end = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.upperBound))
                result[start..<end].foregroundColor = .white
                result[start..<end].backgroundColor = .red
            }
        }

        // Style tag tokens
        if let tagRegex = try? NSRegularExpression(pattern: #"#\w+"#) {
            for match in tagRegex.matches(in: plainText, range: NSRange(plainText.startIndex..., in: plainText)) {
                guard let range = Range(match.range, in: plainText) else { continue }
                let start = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.lowerBound))
                let end = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.upperBound))
                result[start..<end].foregroundColor = .white
                result[start..<end].backgroundColor = .red
            }
        }

        // Style account name tokens
        for account in accounts {
            guard let regex = try? NSRegularExpression(
                pattern: NSRegularExpression.escapedPattern(for: account.name),
                options: .caseInsensitive
            ) else { continue }

            for match in regex.matches(in: plainText, range: NSRange(plainText.startIndex..., in: plainText)) {
                guard let range = Range(match.range, in: plainText) else { continue }
                let start = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.lowerBound))
                let end = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.upperBound))
                result[start..<end].foregroundColor = .white
                result[start..<end].backgroundColor = .red
            }
        }

        // Style category name tokens
        for category in categories {
            guard let regex = try? NSRegularExpression(
                pattern: NSRegularExpression.escapedPattern(for: category.name),
                options: .caseInsensitive
            ) else { continue }

            for match in regex.matches(in: plainText, range: NSRange(plainText.startIndex..., in: plainText)) {
                guard let range = Range(match.range, in: plainText) else { continue }
                let start = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.lowerBound))
                let end = result.index(result.startIndex, offsetByCharacters: plainText.distance(from: plainText.startIndex, to: range.upperBound))
                result[start..<end].foregroundColor = .white
                result[start..<end].backgroundColor = .red
            }
        }

        return result
    }
}
