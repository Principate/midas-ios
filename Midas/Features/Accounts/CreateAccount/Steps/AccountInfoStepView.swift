//
//  AccountInfoStepView.swift
//  Midas
//

import SwiftUI

struct AccountInfoStepView: View {
    @Bindable var viewModel: CreateAccountViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Title
                Text("Account Information")
                    .font(.system(size: 32, weight: .regular, design: .serif))

                Text("Define the foundational details for your new account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Account Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACCOUNT NAME")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    TextField("e.g. Global Checking", text: $viewModel.name)
                        .font(.body)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Account Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACCOUNT TYPE")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    Picker("Account Type", selection: $viewModel.accountType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Currency
                VStack(alignment: .leading, spacing: 8) {
                    Text("CURRENCY")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    Picker("Currency", selection: $viewModel.currencySymbol) {
                        ForEach(CurrencyOption.allOptions) { option in
                            Text("\(option.code) (\(option.symbol))").tag(option.symbol)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }

                // Icon
                VStack(alignment: .leading, spacing: 12) {
                    Text("ACCOUNT ICON")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        ForEach(AccountIconType.allCases, id: \.self) { iconType in
                            iconButton(iconType)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }

    private func iconButton(_ iconType: AccountIconType) -> some View {
        let isSelected = viewModel.iconType == iconType

        return Button {
            viewModel.iconType = iconType
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.brandDarkGreen : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.brandDarkGreen : Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: iconType.systemImageName)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountInfoStepView(
        viewModel: CreateAccountViewModel(accountRepository: InMemoryAccountRepository())
    )
}
