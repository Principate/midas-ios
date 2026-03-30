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

                Text("Configure the operational parameters for your \(viewModel.accountType.displayName.lowercased()) account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                switch viewModel.accountType {
                case .creditCard:
                    creditCardFields
                case .savings:
                    savingsFields
                case .checking:
                    checkingFields
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }

    // MARK: - Credit Card Fields

    private var creditCardFields: some View {
        Group {
            fieldSection(title: "CREDIT LIMIT", prefix: CurrencyOption.symbol(forCode: viewModel.currency), text: $viewModel.creditLimitString, placeholder: "0.00", hint: "The maximum credit limit for this card.", keyboardType: .decimalPad)

            fieldSection(title: "DUE DATE (DAY OF MONTH)", text: $viewModel.dueDateString, placeholder: "1", hint: "The day of the month the payment is due (1–31).", keyboardType: .numberPad)

            fieldSection(title: "CLOSE DATE (DAY OF MONTH)", text: $viewModel.closeDateString, placeholder: "1", hint: "The day of the month the billing cycle closes (1–31).", keyboardType: .numberPad)
        }
    }

    // MARK: - Savings Fields

    private var savingsFields: some View {
        Group {
            fieldSection(title: "MINIMUM AMOUNT", prefix: CurrencyOption.symbol(forCode: viewModel.currency), text: $viewModel.minimumAmountString, placeholder: "0.00", hint: "Leave as 0 if no minimum is required.", keyboardType: .decimalPad)

            fieldSection(title: "INTEREST RATE", text: $viewModel.interestRateString, placeholder: "0.00", suffix: "%", hint: "Annual percentage rate, if applicable.", keyboardType: .decimalPad)
        }
    }

    // MARK: - Checking Fields

    private var checkingFields: some View {
        Group {
            fieldSection(title: "MINIMUM AMOUNT", prefix: CurrencyOption.symbol(forCode: viewModel.currency), text: $viewModel.minimumAmountString, placeholder: "0.00", hint: "Leave as 0 if no minimum is required.", keyboardType: .decimalPad)

            fieldSection(title: "INTEREST RATE", text: $viewModel.interestRateString, placeholder: "0.00", suffix: "%", hint: "Annual percentage rate, if applicable.", keyboardType: .decimalPad)

            fieldSection(title: "OVERDRAFT LIMIT", prefix: CurrencyOption.symbol(forCode: viewModel.currency), text: $viewModel.overdraftLimitString, placeholder: "0.00", hint: "Leave as 0 if overdraft protection is not enabled.", keyboardType: .decimalPad)
        }
    }

    // MARK: - Reusable Field

    private func fieldSection(
        title: String,
        prefix: String? = nil,
        text: Binding<String>,
        placeholder: String,
        suffix: String? = nil,
        hint: String,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2)
                .tracking(2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                if let prefix {
                    Text(prefix)
                        .foregroundStyle(.secondary)
                }
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                if let suffix {
                    Text(suffix)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.body)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            Text(hint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()
        }
    }
}

#Preview {
    AccountSpecificsStepView(
        viewModel: {
            let vm = CreateAccountViewModel(accountRepository: InMemoryAccountRepository())
            vm.accountType = .checking
            return vm
        }()
    )
}
