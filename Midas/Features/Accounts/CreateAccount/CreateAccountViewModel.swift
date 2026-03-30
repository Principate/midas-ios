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
    var isSaving: Bool = false
    var saveError: String?

    // MARK: - Step 1: Account Info

    var name: String = ""
    var accountType: AccountType = .checking {
        didSet {
            // Reset specifics when type changes
            if oldValue != accountType {
                resetSpecificsFields()
            }
        }
    }
    var currency: String = "USD"
    var icon: AccountIcon = .bank
    var color: String = AccountColor.black.rawValue

    // MARK: - Step 2: Account Specifics (type-dependent)

    // Credit Card fields
    var creditLimitString: String = ""
    var dueDateString: String = ""
    var closeDateString: String = ""

    // Savings / Checking shared fields
    var minimumAmountString: String = ""
    var interestRateString: String = ""

    // Checking-only field
    var overdraftLimitString: String = ""

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

    // MARK: - Step Validation

    var isStep1Valid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isStep2Valid: Bool {
        switch accountType {
        case .creditCard:
            guard let limit = Double(creditLimitString), limit >= 0 else { return false }
            guard let due = Int(dueDateString), (1...31).contains(due) else { return false }
            guard let close = Int(closeDateString), (1...31).contains(close) else { return false }
            return true
        case .savings:
            if !minimumAmountString.isEmpty, Double(minimumAmountString) == nil { return false }
            if !interestRateString.isEmpty, Double(interestRateString) == nil { return false }
            return true
        case .checking:
            if !minimumAmountString.isEmpty, Double(minimumAmountString) == nil { return false }
            if !interestRateString.isEmpty, Double(interestRateString) == nil { return false }
            if !overdraftLimitString.isEmpty, Double(overdraftLimitString) == nil { return false }
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
        let option = CurrencyOption.allOptions.first { $0.code == currency }
        return option.map { "\($0.code) (\($0.symbol))" } ?? currency
    }

    // MARK: - Build Info

    private func buildAccountInfo() -> AccountInfo {
        switch accountType {
        case .creditCard:
            return .creditCard(
                limit: Double(creditLimitString) ?? 0,
                dueDate: Int(dueDateString) ?? 1,
                closeDate: Int(closeDateString) ?? 1
            )
        case .savings:
            return .savings(
                minimumAmount: Double(minimumAmountString) ?? 0,
                interestRate: Double(interestRateString) ?? 0
            )
        case .checking:
            return .checking(
                minimumAmount: Double(minimumAmountString) ?? 0,
                interestRate: Double(interestRateString) ?? 0,
                overdraftLimit: Double(overdraftLimitString) ?? 0
            )
        }
    }

    // MARK: - Save

    func saveAccount() async {
        guard isStep1Valid, isStep2Valid, isStep3Valid,
              let balance = parsedBalance else { return }

        let account = Account(
            name: name.trimmingCharacters(in: .whitespaces),
            currency: currency,
            initialBalance: balance,
            color: color,
            icon: icon.rawValue,
            accountType: accountType,
            info: buildAccountInfo()
        )

        isSaving = true
        saveError = nil

        do {
            try await accountRepository.addAccount(account)
            didSave = true
        } catch {
            saveError = error.localizedDescription
        }

        isSaving = false
    }

    // MARK: - Private

    private func resetSpecificsFields() {
        creditLimitString = ""
        dueDateString = ""
        closeDateString = ""
        minimumAmountString = ""
        interestRateString = ""
        overdraftLimitString = ""
    }
}
