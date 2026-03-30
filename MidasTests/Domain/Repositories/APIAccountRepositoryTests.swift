//
//  APIAccountRepositoryTests.swift
//  MidasTests
//

import Testing
import Foundation
@testable import Midas

@MainActor
struct APIAccountRepositoryTests {

    // MARK: - Helpers

    private func makeRepository(
        apiClient: MockAPIClient = MockAPIClient()
    ) -> (APIAccountRepository, MockAPIClient) {
        let repo = APIAccountRepository(apiClient: apiClient)
        return (repo, apiClient)
    }

    private func makeSampleAccount() -> Account {
        Account(
            name: "Test Account",
            currency: "USD",
            initialBalance: 1000,
            icon: AccountIcon.bank.rawValue,
            accountType: .checking,
            info: .checking(minimumAmount: 0, interestRate: 0, overdraftLimit: 0)
        )
    }

    // MARK: - addAccount

    @Test func test_addAccount_shouldPostToAccountsPath() async throws {
        let (repo, client) = makeRepository()
        let account = makeSampleAccount()
        try await repo.addAccount(account)
        #expect(client.lastPostPath == "/api/v1/accounts")
    }

    @Test func test_addAccount_shouldCallPostExactlyOnce() async throws {
        let (repo, client) = makeRepository()
        let account = makeSampleAccount()
        try await repo.addAccount(account)
        #expect(client.postCallCount == 1)
    }

    @Test func test_addAccount_shouldAppendToLocalAccounts() async throws {
        let (repo, _) = makeRepository()
        let account = makeSampleAccount()
        try await repo.addAccount(account)
        #expect(repo.accounts.count == 1)
        #expect(repo.accounts.first?.name == "Test Account")
    }

    @Test func test_addAccount_shouldSendAccountAsJSON() async throws {
        let (repo, client) = makeRepository()
        let account = makeSampleAccount()
        try await repo.addAccount(account)

        let bodyData = try #require(client.lastPostBodyData)
        let json = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
        #expect(json?["name"] as? String == "Test Account")
        #expect(json?["currency"] as? String == "USD")
        #expect(json?["initialBalance"] as? Double == 1000)
    }

    @Test func test_addAccount_whenPostFails_shouldThrow() async {
        let client = MockAPIClient()
        client.postError = NetworkError.httpError(statusCode: 500)
        let (repo, _) = makeRepository(apiClient: client)
        let account = makeSampleAccount()

        do {
            try await repo.addAccount(account)
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }
    }

    @Test func test_addAccount_whenPostFails_shouldNotAppendToLocalAccounts() async {
        let client = MockAPIClient()
        client.postError = NetworkError.httpError(statusCode: 500)
        let (repo, _) = makeRepository(apiClient: client)
        let account = makeSampleAccount()

        try? await repo.addAccount(account)
        #expect(repo.accounts.isEmpty)
    }

    // MARK: - loadInitialAccounts

    @Test func test_loadInitialAccounts_shouldGetFromAccountsPath() async throws {
        let client = MockAPIClient()
        client.stubbedGetResult = try makeAccountsJSON([makeSampleAccount()])
        let (repo, _) = makeRepository(apiClient: client)
        try await repo.loadInitialAccounts()
        #expect(client.lastGetPath == "/api/v1/accounts")
    }

    @Test func test_loadInitialAccounts_shouldCallGetExactlyOnce() async throws {
        let client = MockAPIClient()
        client.stubbedGetResult = try makeAccountsJSON([makeSampleAccount()])
        let (repo, _) = makeRepository(apiClient: client)
        try await repo.loadInitialAccounts()
        #expect(client.getCallCount == 1)
    }

    @Test func test_loadInitialAccounts_shouldPopulateAccounts() async throws {
        let client = MockAPIClient()
        client.stubbedGetResult = try makeAccountsJSON([makeSampleAccount()])
        let (repo, _) = makeRepository(apiClient: client)
        try await repo.loadInitialAccounts()
        #expect(repo.accounts.count == 1)
        #expect(repo.accounts.first?.name == "Test Account")
    }

    @Test func test_loadInitialAccounts_whenGetFails_shouldThrow() async {
        let client = MockAPIClient()
        client.getError = NetworkError.httpError(statusCode: 500)
        let (repo, _) = makeRepository(apiClient: client)

        do {
            try await repo.loadInitialAccounts()
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }
    }

    @Test func test_loadInitialAccounts_whenGetFails_shouldKeepAccountsEmpty() async {
        let client = MockAPIClient()
        client.getError = NetworkError.httpError(statusCode: 500)
        let (repo, _) = makeRepository(apiClient: client)
        try? await repo.loadInitialAccounts()
        #expect(repo.accounts.isEmpty)
    }

    // MARK: - Initial State

    @Test func test_init_shouldHaveEmptyAccounts() {
        let (repo, _) = makeRepository()
        #expect(repo.accounts.isEmpty)
    }

    // MARK: - JSON Helpers

    private func makeAccountsJSON(_ accounts: [Account]) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(accounts)
    }
}
