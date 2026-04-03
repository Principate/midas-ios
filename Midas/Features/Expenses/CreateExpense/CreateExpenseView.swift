//
//  CreateExpenseView.swift
//  Midas
//
//  Created by Bruno Lemus on 1/4/26.
//


import SwiftUI

struct AmountToken: Equatable {
    let value: Double
    let currency: String
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = CurrencyOption.symbol(forCode: currency)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct AccountToken: Equatable {
    let accountId: UUID
    let accountName: String
}

struct CreateExpenseView: View {
    
    let accounts: [Account]
    let categories: [ExpenseCategory]
    var onDismiss: (() -> Void)?
    
    @State private var text = AttributedString("")
    @State private var amount: AmountToken?
    @State private var account: AccountToken?
    @State private var tags: [String] = []
    @State private var transactionDate = Date()
    @State private var counterparty: String = ""
    @State private var category: ExpenseCategory?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            navigationBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: - Natural Language Input
                    naturalLanguageInputSection
                    
                    sectionDivider
                    
                    // MARK: - Detected Entities
                    detectedEntitiesSection
                    
                    sectionDivider
                    
                    // MARK: - Transaction Date
                    transactionDateSection
                }
                .padding(.horizontal, 24)
            }
            
        }
        .background(Color(.systemBackground))
        .onChange(of: text) { _, newValue in
            let plainText = String(newValue.characters)
            amount = CreateExpenseView.parseAmountToken(from: plainText)
            account = CreateExpenseView.parseAccountToken(from: plainText, accounts: accounts)
            tags = CreateExpenseView.parseTags(from: plainText)
            category = CreateExpenseView.parseCategory(from: plainText, categories: categories)
            
            let styled = CreateExpenseView.applyStyling(
                to: newValue,
                accounts: accounts,
                categories: categories
            )
            if styled != text {
                text = styled
            }
        }.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                recordTransactionButton
            }
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack {
            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text("Editorial Wealth")
                .font(.system(size: 17, design: .serif))
                .italic()
            
            Spacer()
            
            // Placeholder for right-side icon to balance layout
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.brandGold.opacity(0.3))
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
    
    // MARK: - Natural Language Input Section
    
    private var naturalLanguageInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("NATURAL LANGUAGE INPUT")
            
            TextEditor(text: $text)
                .font(.system(size: 28, design: .serif))
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Detected Entities Section
    
    private var detectedEntitiesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with live parsing indicator
            HStack {
                sectionHeader("DETECTED ENTITIES")
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.brandGold)
                        .frame(width: 6, height: 6)
                    Text("LIVE PARSING ACTIVE")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.5)
                        .foregroundStyle(Color.brandGold)
                }
            }
            .padding(.top, 20)
            
            // Value & Currency
            entityGroup("VALUE & CURRENCY") {
                if let amount {
                    HStack(spacing: 12) {
                        entityField(amount.formattedValue, icon: "pencil")
                        entityPill(amount.currency)
                    }
                } else {
                    entityFieldPlaceholder("Enter amount...")
                }
            }
            
            // Counterparty
            entityGroup("COUNTERPARTY") {
                entityField(
                    counterparty.isEmpty ? "—" : counterparty,
                    icon: "building.2",
                    isEmpty: counterparty.isEmpty
                )
            }
            
            // Source Account
            entityGroup("SOURCE ACCOUNT") {
                if let account {
                    entityField(account.accountName, icon: "building.columns")
                } else {
                    entityFieldPlaceholder("No account detected")
                }
            }
            
            // Classification
            entityGroup("CLASSIFICATION") {
                if let category {
                    entityField(category.name, icon: "slider.horizontal.3")
                } else {
                    entityFieldPlaceholder("No category detected")
                }
            }
            
            // Labels & Tags
            entityGroup("LABELS & TAGS") {
                TagChipsView(
                    tags: tags,
                    onRemove: { tagToRemove in
                        tags.removeAll { $0 == tagToRemove }
                    },
                    onAdd: { }
                )
            }
        }
    }
    
    // MARK: - Transaction Date Section
    
    private var transactionDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("TRANSACTION DATE")
                .padding(.top, 20)
            
            HStack {
                Text(transactionDate, format: .dateTime.weekday(.wide).month(.abbreviated).day().year())
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Record Transaction Button
    
    private var recordTransactionButton: some View {
        Button {
            // Record action
        } label: {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.brandDarkGreen)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // MARK: - Reusable UI Components
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.5)
            .foregroundStyle(Color.brandOlive)
    }
    
    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(height: 1)
    }
    
    private func entityGroup<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.brandOlive)
            content()
        }
    }
    
    private func entityField(_ value: String, icon: String, isEmpty: Bool = false) -> some View {
        HStack {
            Text(value)
                .font(.system(size: 16))
                .foregroundStyle(isEmpty ? .secondary : .primary)
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }
    
    private func entityPill(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
            )
    }
    
    private func entityFieldPlaceholder(_ placeholder: String) -> some View {
        HStack {
            Text(placeholder)
                .font(.system(size: 16))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Amount Parsing
    
    static func parseAmountToken(from plainText: String) -> AmountToken? {
        guard let regex = try? NSRegularExpression(
            pattern: #"(\d+(?:\.\d+)?)\s([A-Z]{3})"#
        ) else {
            return nil
        }
        
        guard let match = regex.firstMatch(
            in: plainText,
            range: NSRange(plainText.startIndex..., in: plainText)
        ) else {
            return nil
        }
        
        guard let valueRange = Range(match.range(at: 1), in: plainText),
              let currencyRange = Range(match.range(at: 2), in: plainText),
              let value = Double(plainText[valueRange])
        else {
            return nil
        }
        
        return AmountToken(value: value, currency: String(plainText[currencyRange]))
    }
    
    // MARK: - Account Parsing
    
    static func parseAccountToken(from plainText: String, accounts: [Account]) -> AccountToken? {
        let lowercasedText = plainText.lowercased()
        let sorted = accounts.sorted { $0.name.count > $1.name.count }
        
        for account in sorted {
            if lowercasedText.contains(account.name.lowercased()) {
                return AccountToken(accountId: account.id, accountName: account.name)
            }
        }
        
        return nil
    }
    
    // MARK: - Tag Parsing
    
    static func parseTags(from plainText: String) -> [String] {
        guard let regex = try? NSRegularExpression(
            pattern: #"#(\w+)"#
        ) else {
            return []
        }
        
        let matches = regex.matches(
            in: plainText,
            range: NSRange(plainText.startIndex..., in: plainText)
        )
        
        var seen = Set<String>()
        var result: [String] = []
        
        for match in matches {
            guard let range = Range(match.range(at: 1), in: plainText) else { continue }
            let tag = String(plainText[range])
            if seen.insert(tag).inserted {
                result.append(tag)
            }
        }
        
        return result
    }
    
    // MARK: - Category Parsing
    
    /// Matches category names case-insensitively in the text.
    /// Prefers longer names first (e.g. "Bills & Utilities" over "Bills").
    static func parseCategory(from plainText: String, categories: [ExpenseCategory]) -> ExpenseCategory? {
        let lowercasedText = plainText.lowercased()
        let sorted = categories.sorted { $0.name.count > $1.name.count }
        
        for category in sorted {
            if lowercasedText.contains(category.name.lowercased()) {
                return category
            }
        }
        
        return nil
    }
    
    // MARK: - Styling
    
    static func applyStyling(
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
            pattern: #"\d+(?:\.\d+)?\s[A-Z]{3}"#
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

#Preview {
    CreateExpenseView(
        accounts: [
            Account(name: "Primary Checking", currency: "USD", initialBalance: 10000),
            Account(name: "Savings", currency: "USD", initialBalance: 5000),
        ],
        categories: [
            ExpenseCategory(name: "Groceries", color: "#4CAF50"),
            ExpenseCategory(name: "Dining", color: "#FF9800"),
            ExpenseCategory(name: "Transport", color: "#2196F3"),
            ExpenseCategory(name: "Shopping", color: "#E91E63"),
        ]
    )
}
