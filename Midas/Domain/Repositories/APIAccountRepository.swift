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

    func loadInitialAccounts() async throws {
        let data = try await apiClient.get(path: "/api/v1/accounts")
        let decoder = JSONDecoder()
        accounts = try decoder.decode([Account].self, from: data)
    }

    func addAccount(_ account: Account) async throws {
        _ = try await apiClient.post(path: "/api/v1/accounts", body: account)
        accounts.append(account)
    }
}
