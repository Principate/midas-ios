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

                    Picker("Currency", selection: $viewModel.currency) {
                        ForEach(CurrencyOption.allOptions) { option in
                            Text("\(option.code) (\(option.symbol))").tag(option.code)
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
                        ForEach(AccountIcon.allCases, id: \.self) { accountIcon in
                            iconButton(accountIcon)
                        }
                    }
                }

                // Color
                VStack(alignment: .leading, spacing: 12) {
                    Text("ACCOUNT COLOR")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        ForEach(AccountColor.allCases, id: \.self) { accountColor in
                            colorButton(accountColor)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }

    private func iconButton(_ accountIcon: AccountIcon) -> some View {
        let isSelected = viewModel.icon == accountIcon

        return Button {
            viewModel.icon = accountIcon
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

                Image(systemName: accountIcon.systemImageName)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }

    private func colorButton(_ accountColor: AccountColor) -> some View {
        let isSelected = viewModel.color == accountColor.rawValue
        let displayColor = Color(hex: accountColor.rawValue) ?? .black

        return Button {
            viewModel.color = accountColor.rawValue
        } label: {
            ZStack {
                Circle()
                    .fill(displayColor)
                    .frame(width: 36, height: 36)

                if isSelected {
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountInfoStepView(
        viewModel: CreateAccountViewModel(accountRepository: InMemoryAccountRepository())
    )
}
