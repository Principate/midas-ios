//
//  AccountRepositoryProtocol.swift
//  Midas
//

import Foundation

@MainActor
protocol AccountRepositoryProtocol: AnyObject {
    var accounts: [Account] { get }
    func loadInitialAccounts() async throws
    func addAccount(_ account: Account) async throws
}
