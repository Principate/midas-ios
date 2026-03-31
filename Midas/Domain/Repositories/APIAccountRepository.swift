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
        print("Fetching accounts....")
        let data = try await apiClient.get(path: "/api/v1/accounts")
        print("Got response: \(data)")
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        accounts = try decoder.decode([Account].self, from: data)
        print("Decoded accounts: \(accounts)")
    }

    func addAccount(_ account: Account) async throws {
        _ = try await apiClient.post(path: "/api/v1/accounts", body: account)
        accounts.append(account)
    }
}

