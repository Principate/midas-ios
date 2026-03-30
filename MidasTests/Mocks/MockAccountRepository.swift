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
    var addAccountError: Error?
    var loadInitialAccountsError: Error?
    var stubbedAccounts: [Account]?

    func loadInitialAccounts() async throws {
        loadInitialAccountsCallCount += 1
        if let error = loadInitialAccountsError {
            throw error
        }
        if let stubbed = stubbedAccounts {
            accounts = stubbed
        }
    }

    func addAccount(_ account: Account) async throws {
        addAccountCallCount += 1
        lastAddedAccount = account
        if let error = addAccountError {
            throw error
        }
        accounts.append(account)
    }
}
