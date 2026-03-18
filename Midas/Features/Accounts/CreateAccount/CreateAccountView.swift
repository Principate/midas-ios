//
//  CreateAccountView.swift
//  Midas
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateAccountViewModel

    init(accountRepository: AccountRepositoryProtocol) {
        _viewModel = State(initialValue: CreateAccountViewModel(accountRepository: accountRepository))
    }

    var body: some View {
        NavigationStack {
            Form {
                accountDetailsSection
                currencySection
                balanceSection
                iconSection
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveAccount()
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .onChange(of: viewModel.didSave) { _, didSave in
                if didSave { dismiss() }
            }
        }
    }
}

// MARK: - Form Sections

private extension CreateAccountView {
    var accountDetailsSection: some View {
        Section("Account Details") {
            TextField("Account Name", text: $viewModel.name)
            TextField("Subtitle", text: $viewModel.subtitle)
        }
    }

    var currencySection: some View {
        Section("Currency") {
            Picker("Symbol", selection: $viewModel.currencySymbol) {
                ForEach(CreateAccountViewModel.currencySymbolOptions, id: \.self) { symbol in
                    Text(symbol).tag(symbol)
                }
            }
        }
    }

    var balanceSection: some View {
        Section("Initial Balance") {
            TextField("0.00", text: $viewModel.balanceString)
                .keyboardType(.decimalPad)
        }
    }

    var iconSection: some View {
        Section("Icon") {
            Picker("Icon", selection: $viewModel.iconType) {
                ForEach(AccountIconType.allCases, id: \.self) { iconType in
                    Label(iconType.rawValue.capitalized, systemImage: iconType.systemImageName)
                        .tag(iconType)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }
}

#Preview {
    CreateAccountView(accountRepository: InMemoryAccountRepository())
}
