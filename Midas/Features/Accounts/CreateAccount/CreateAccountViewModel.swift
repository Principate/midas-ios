//
//  CreateAccountViewModel.swift
//  Midas
//

import Foundation

// MARK: - Create Account Step

enum CreateAccountStep: Int, CaseIterable {
    case accountInfo = 1
    case accountSpecifics = 2
    case finalize = 3

    var title: String {
        switch self {
        case .accountInfo: return "Account Information"
        case .accountSpecifics: return "Account Specifics"
        case .finalize: return "Finalize Account"
        }
    }

    var progressPercentage: Int {
        switch self {
        case .accountInfo: return 33
        case .accountSpecifics: return 66
        case .finalize: return 100
        }
    }
}

// MARK: - View Model

@Observable
@MainActor
class CreateAccountViewModel {

    // MARK: - Navigation State

    var currentStep: CreateAccountStep = .accountInfo
    var didSave: Bool = false

    // MARK: - Step 1: Account Info

    var name: String = ""
    var accountType: AccountType = .checking
    var currencySymbol: String = "$"
    var iconType: AccountIconType = .bank

    // MARK: - Step 2: Credit Card Fields

    var creditLimitString: String = ""
    var statementCloseDate: Date = Date()
    var paymentDueDate: Date = Date()

    // MARK: - Step 2: Savings / Checking Fields

    var minimumBalanceString: String = ""
    var hasMinimumBalanceRequirement: Bool = false

    // MARK: - Step 3: Finalize

    var balanceString: String = ""

    // MARK: - Dependencies

    private let accountRepository: AccountRepositoryProtocol

    init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }

    // MARK: - Parsed Values

    var parsedBalance: Double? {
        Double(balanceString)
    }

    var parsedCreditLimit: Double? {
        Double(creditLimitString)
    }

    var parsedMinimumBalance: Double? {
        Double(minimumBalanceString)
    }

    // MARK: - Step Validation

    var isStep1Valid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isStep2Valid: Bool {
        switch accountType {
        case .creditCard:
            guard let limit = parsedCreditLimit, limit > 0 else { return false }
            return true
        case .savings, .checking:
            if hasMinimumBalanceRequirement {
                guard let minBal = parsedMinimumBalance, minBal >= 0 else { return false }
                return true
            }
            return true
        }
    }

    var isStep3Valid: Bool {
        guard let balance = parsedBalance, balance >= 0 else { return false }
        return true
    }

    var isCurrentStepValid: Bool {
        switch currentStep {
        case .accountInfo: return isStep1Valid
        case .accountSpecifics: return isStep2Valid
        case .finalize: return isStep3Valid
        }
    }

    // MARK: - Navigation

    func goToNextStep() {
        guard isCurrentStepValid else { return }
        switch currentStep {
        case .accountInfo:
            currentStep = .accountSpecifics
        case .accountSpecifics:
            currentStep = .finalize
        case .finalize:
            break
        }
    }

    func goToPreviousStep() {
        switch currentStep {
        case .accountInfo:
            break
        case .accountSpecifics:
            currentStep = .accountInfo
        case .finalize:
            currentStep = .accountSpecifics
        }
    }

    // MARK: - Display Helpers

    var currencyDisplayString: String {
        let option = CurrencyOption.allOptions.first { $0.symbol == currencySymbol }
        return option.map { "\($0.code) (\($0.symbol))" } ?? currencySymbol
    }

    // MARK: - Save

    func saveAccount() {
        guard isStep1Valid, isStep2Valid, isStep3Valid,
              let balance = parsedBalance else { return }

        let details: AccountTypeDetails
        switch accountType {
        case .creditCard:
            guard let limit = parsedCreditLimit else { return }
            details = .creditCard(
                creditLimit: limit,
                statementCloseDate: statementCloseDate,
                paymentDueDate: paymentDueDate
            )
        case .savings:
            details = .savings(
                minimumBalance: hasMinimumBalanceRequirement ? parsedMinimumBalance : nil
            )
        case .checking:
            details = .checking(
                minimumBalance: hasMinimumBalanceRequirement ? parsedMinimumBalance : nil
            )
        }

        let account = Account(
            name: name.trimmingCharacters(in: .whitespaces),
            accountType: accountType,
            currencySymbol: currencySymbol,
            balance: balance,
            iconType: iconType,
            typeDetails: details
        )

        accountRepository.addAccount(account)
        didSave = true
    }
}
