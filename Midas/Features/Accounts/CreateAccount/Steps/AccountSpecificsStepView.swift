//
//  AccountSpecificsStepView.swift
//  Midas
//

import SwiftUI

struct AccountSpecificsStepView: View {
    @Bindable var viewModel: CreateAccountViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Title
                Text("Account Specifics")
                    .font(.system(size: 32, weight: .regular, design: .serif))

                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Type-specific fields
                switch viewModel.accountType {
                case .creditCard:
                    creditCardFields
                case .savings, .checking:
                    savingsCheckingFields
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }

    private var subtitleText: String {
        switch viewModel.accountType {
        case .creditCard:
            return "Please refine the operational details for your new credit portfolio."
        case .savings:
            return "Configure the parameters for your new savings account."
        case .checking:
            return "Configure the parameters for your new checking account."
        }
    }

    // MARK: - Credit Card Fields

    private var creditCardFields: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Credit Limit
            VStack(alignment: .leading, spacing: 8) {
                Text("CREDIT LIMIT")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text("$")
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $viewModel.creditLimitString)
                        .keyboardType(.decimalPad)
                }
                .font(.body)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }

            // Statement Close Date
            VStack(alignment: .leading, spacing: 8) {
                Text("STATEMENT CLOSE DATE")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)

                DatePicker(
                    "",
                    selection: $viewModel.statementCloseDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }

            // Payment Due Date
            VStack(alignment: .leading, spacing: 8) {
                Text("PAYMENT DUE DATE")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)

                DatePicker(
                    "",
                    selection: $viewModel.paymentDueDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Savings / Checking Fields

    private var savingsCheckingFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Requirements")
                .font(.system(size: 22, weight: .regular, design: .serif))

            VStack(alignment: .leading, spacing: 8) {
                Text("MINIMUM BALANCE REQUIREMENT")
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text("$")
                        .foregroundStyle(.secondary)
                    TextField("2,500.00", text: $viewModel.minimumBalanceString)
                        .keyboardType(.decimalPad)
                        .onChange(of: viewModel.minimumBalanceString) { _, newValue in
                            viewModel.hasMinimumBalanceRequirement =
                                !newValue.trimmingCharacters(in: .whitespaces).isEmpty
                        }
                }
                .font(.body)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                Text("Leave blank if no minimum is required for this account type.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }
}

#Preview {
    AccountSpecificsStepView(
        viewModel: {
            let vm = CreateAccountViewModel(accountRepository: InMemoryAccountRepository())
            vm.accountType = .creditCard
            return vm
        }()
    )
}
