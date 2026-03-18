//
//  CreateAccountViewModel.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class CreateAccountViewModel {
    var name: String = ""
    var subtitle: String = ""
    var currencySymbol: String = "$"
    var balanceString: String = ""
    var iconType: AccountIconType = .bank
    var didSave: Bool = false

    static let currencySymbolOptions = ["$", "€", "£", "¥", "CHF"]

    private let accountRepository: AccountRepositoryProtocol

    init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }

    var parsedBalance: Double? {
        Double(balanceString)
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !subtitle.trimmingCharacters(in: .whitespaces).isEmpty
        && !currencySymbol.trimmingCharacters(in: .whitespaces).isEmpty
        && parsedBalance != nil
        && (parsedBalance ?? -1) >= 0
    }

    func saveAccount() {
        guard isFormValid, let balance = parsedBalance else { return }

        let account = Account(
            name: name.trimmingCharacters(in: .whitespaces),
            subtitle: subtitle.trimmingCharacters(in: .whitespaces),
            currencySymbol: currencySymbol,
            balance: balance,
            iconType: iconType
        )

        accountRepository.addAccount(account)
        didSave = true
    }
}
