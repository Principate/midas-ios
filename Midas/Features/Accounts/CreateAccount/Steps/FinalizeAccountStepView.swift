//
//  FinalizeAccountStepView.swift
//  Midas
//

import SwiftUI

struct FinalizeAccountStepView: View {
    @Bindable var viewModel: CreateAccountViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Title
                Text("Finalize Account")
                    .font(.system(size: 32, weight: .regular, design: .serif))

                // Current Balance
                VStack(alignment: .leading, spacing: 8) {
                    Text("INITIAL BALANCE")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(CurrencyOption.symbol(forCode: viewModel.currency))
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundStyle(.secondary)

                        TextField("0.00", text: $viewModel.balanceString)
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .keyboardType(.decimalPad)
                    }
                    .padding(.bottom, 8)

                    Divider()

                    Text("Enter the current market value of your holdings as of today.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }

                Spacer(minLength: 40)

                // Account Summary
                accountSummary
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }

    // MARK: - Account Summary

    private var accountSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACCOUNT SUMMARY")
                .font(.caption2)
                .tracking(2)
                .foregroundStyle(.secondary)

            // Account name row
            HStack(spacing: 12) {
                // Icon with color
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: viewModel.color) ?? .black)
                        .frame(width: 44, height: 44)

                    Image(systemName: viewModel.icon.systemImageName)
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("ACCOUNT NAME")
                        .font(.caption2)
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    Text(viewModel.name)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                }

                Spacer()

                Button {
                    viewModel.currentStep = .accountInfo
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }

            Divider()
                .foregroundStyle(Color.gray.opacity(0.3))

            // Type and Currency row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TYPE")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    Text(viewModel.accountType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENCY")
                        .font(.caption2)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    Text(viewModel.currencyDisplayString)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    FinalizeAccountStepView(
        viewModel: {
            let vm = CreateAccountViewModel(accountRepository: InMemoryAccountRepository())
            vm.name = "Global Equities Portfolio"
            vm.accountType = .creditCard
            vm.currency = "USD"
            vm.icon = .bank
            return vm
        }()
    )
}
