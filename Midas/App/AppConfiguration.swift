//
//  AppConfiguration.swift
//  Midas
//

import Foundation

enum AppConfiguration {
    static var apiBaseURL: URL {
        guard let urlString = ProcessInfo.processInfo.environment["API_BASE_URL"],
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return URL(string: "http://localhost:8080")!
        }
        return url
    }
}
