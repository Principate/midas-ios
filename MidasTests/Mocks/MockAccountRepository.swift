//
//  MockAccountRepository.swift
//  MidasTests
//

import Foundation
@testable import Midas

@Observable
@MainActor
class MockAccountRepository: AccountRepositoryProtocol {
    var accounts: [Account] = []
    var loadInitialAccountsCallCount = 0
    var addAccountCallCount = 0
    var lastAddedAccount: Account?

    func loadInitialAccounts() {
        loadInitialAccountsCallCount += 1
    }

    func addAccount(_ account: Account) {
        addAccountCallCount += 1
        lastAddedAccount = account
        accounts.append(account)
    }
}
