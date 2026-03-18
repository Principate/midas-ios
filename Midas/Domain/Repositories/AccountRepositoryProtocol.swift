//
//  AccountRepositoryProtocol.swift
//  Midas
//

import Foundation

@MainActor
protocol AccountRepositoryProtocol: AnyObject {
    var accounts: [Account] { get }
    func loadInitialAccounts()
    func addAccount(_ account: Account)
}
