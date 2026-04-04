//
//  CreateExpenseView.swift
//  Midas
//
//  Created by Bruno Lemus on 1/4/26.
//

import SwiftUI

struct CreateExpenseView: View {
    
    @State var viewModel: LogExpenseViewModel
    var onDismiss: (() -> Void)?
    
    @State private var transactionDate = Date()
    @State private var isShowingCreateAccount = false
    @State private var isShowingCreateCategory = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                naturalLanguageInputSection
                sectionDivider
                
                detectedEntitiesSection
                sectionDivider
                
                transactionDateSection
            }
            .padding(.horizontal, 24)
            
            // Autocomplete overlay anchored below the text input area
            if viewModel.showAutocompleteSuggestions {
                autocompleteOverlay
                    .padding(.horizontal, 24)
                    // Offset below the input section (header + text editor area)
                    .padding(.top, 160)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Add Expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    Task { await viewModel.saveExpense()}
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .disabled(!viewModel.canSave || viewModel.isSaving)
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateAccount) {
            CreateAccountView(accountRepository: viewModel.accountRepository)
        }
        .sheet(isPresented: $isShowingCreateCategory) {
            CreateCategoryPlaceholderView()
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
            
            TextEditor(text: $viewModel.inputText)
                .font(.system(size: 28, design: .serif))
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Autocomplete Overlay
    
    private var autocompleteOverlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header showing trigger context
            HStack(spacing: 6) {
                Image(systemName: viewModel.activeTrigger == .account ? "building.columns" : "slider.horizontal.3")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.brandGold)
                Text(viewModel.activeTrigger == .account ? "ACCOUNTS" : "CATEGORIES")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(Color.brandOlive)
                Spacer()
                if !viewModel.autocompleteQuery.isEmpty {
                    Text("\"\(viewModel.autocompleteQuery)\"")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            if viewModel.activeTrigger == .account {
                accountSuggestionsList
            } else {
                categorySuggestionsList
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
    }
    
    private var accountSuggestionsList: some View {
        let accounts = viewModel.filteredAccounts
        return Group {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if accounts.isEmpty {
                        Text("No matching accounts")
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(accounts) { account in
                            Button {
                                viewModel.selectAccountFromAutocomplete(account)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: account.accountIcon.systemImageName)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(hex: account.color) ?? .primary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(account.name)
                                            .font(.system(size: 15))
                                            .foregroundStyle(.primary)
                                        Text(account.formattedSubtitle)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if account.id != accounts.last?.id {
                                Divider().padding(.leading, 36)
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        isShowingCreateAccount = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.brandGold)
                            Text("Create New Account")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.brandGold)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxHeight: 200)
        }
    }
    
    private var categorySuggestionsList: some View {
        let categories = viewModel.filteredCategories
        return Group {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if categories.isEmpty {
                        Text("No matching categories")
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(categories) { category in
                            Button {
                                viewModel.selectCategoryFromAutocomplete(category)
                            } label: {
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(Color(hex: category.color) ?? .primary)
                                        .frame(width: 8, height: 8)
                                    Text(category.name)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if category.id != categories.last?.id {
                                Divider().padding(.leading, 30)
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        isShowingCreateCategory = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.brandGold)
                            Text("Create New Category")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.brandGold)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxHeight: 200)
        }
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
                if viewModel.effectiveAmount != nil {
                    HStack(spacing: 12) {
                        entityField(viewModel.formattedAmount, icon: "pencil")
                        if let currency = viewModel.effectiveCurrency {
                            entityPill(currency)
                        }
                    }
                } else {
                    entityFieldPlaceholder("Enter amount...")
                }
            }
            
            // Counterparty
            entityGroup("COUNTERPARTY") {
                let title = viewModel.parsedInput.title
                entityField(
                    title.isEmpty ? "—" : title,
                    icon: "building.2",
                    isEmpty: title.isEmpty
                )
            }
            
            // Source Account
            entityGroup("SOURCE ACCOUNT") {
                if let account = viewModel.effectiveAccount {
                    entityField(account.name, icon: "building.columns")
                } else {
                    entityFieldPlaceholder("No account detected")
                }
            }
            
            // Classification
            entityGroup("CLASSIFICATION") {
                if let category = viewModel.effectiveCategory {
                    entityField(category.name, icon: "slider.horizontal.3")
                } else {
                    entityFieldPlaceholder("No category detected")
                }
            }
            
            // Labels & Tags
            entityGroup("LABELS & TAGS") {
                TagChipsView(
                    tags: viewModel.tags,
                    onRemove: { tagToRemove in
                        viewModel.removeTag(tagToRemove)
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
}

// MARK: - Create Category Placeholder

struct CreateCategoryPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "tag")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.brandGold)
                
                Text("Create Category")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .italic()
                
                Text("This feature is coming soon.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        CreateExpenseView(
            viewModel: LogExpenseViewModel(
                accountRepository: InMemoryAccountRepository(),
                expenseRepository: InMemoryExpenseRepository()
            )
        )
    }
}
