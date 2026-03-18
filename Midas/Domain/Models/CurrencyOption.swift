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
        CurrencyOption(id: "$", symbol: "$", code: "USD", name: "US Dollar"),
        CurrencyOption(id: "€", symbol: "€", code: "EUR", name: "Euro"),
        CurrencyOption(id: "£", symbol: "£", code: "GBP", name: "British Pound"),
        CurrencyOption(id: "¥", symbol: "¥", code: "JPY", name: "Japanese Yen"),
        CurrencyOption(id: "CHF", symbol: "CHF", code: "CHF", name: "Swiss Franc"),
    ]
}
