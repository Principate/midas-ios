//
//  CurrencyOption.swift
//  Midas
//

import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let id: String
    let symbol: String
    let code: String
    let name: String

    static let allOptions: [CurrencyOption] = [
        CurrencyOption(id: "USD", symbol: "$", code: "USD", name: "US Dollar"),
        CurrencyOption(id: "EUR", symbol: "€", code: "EUR", name: "Euro"),
        CurrencyOption(id: "GBP", symbol: "£", code: "GBP", name: "British Pound"),
        CurrencyOption(id: "JPY", symbol: "¥", code: "JPY", name: "Japanese Yen"),
        CurrencyOption(id: "CHF", symbol: "CHF", code: "CHF", name: "Swiss Franc"),
    ]

    static func symbol(forCode code: String) -> String {
        allOptions.first { $0.code == code }?.symbol ?? code
    }
}
