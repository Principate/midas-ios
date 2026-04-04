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
        .toolbar {
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

            TextEditor(text: $viewModel.inputText)
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

    // MARK: - Record Transaction Button

    private var recordTransactionButton: some View {
        Button {
            Task { await viewModel.saveExpense() }
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
        .disabled(!viewModel.canSave || viewModel.isSaving)
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
}

#Preview {
    CreateExpenseView(
        viewModel: LogExpenseViewModel(
            accountRepository: InMemoryAccountRepository(),
            expenseRepository: InMemoryExpenseRepository()
        )
    )
}
