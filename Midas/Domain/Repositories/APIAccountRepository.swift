//
//  APIAccountRepository.swift
//  Midas
//

import Foundation

@Observable
@MainActor
class APIAccountRepository: AccountRepositoryProtocol {
    var accounts: [Account] = []

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadInitialAccounts() {
        // TODO: Replace with GET /accounts when available
    }

    func addAccount(_ account: Account) async throws {
        _ = try await apiClient.post(path: "accounts", body: account)
        accounts.append(account)
    }
}
