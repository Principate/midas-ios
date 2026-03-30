//
//  MidasApp.swift
//  Midas
//
//  Created by Bruno Lemus on 17/3/26.
//

import ClerkKit
import ClerkKitUI
import SwiftUI

@main
struct MidasApp: App {

    @State private var clerk = Clerk.configure(
        publishableKey:
            "pk_test_aGFwcHktY3Jhd2RhZC03Ni5jbGVyay5hY2NvdW50cy5kZXYk"
    )

    @State private var accountRepository: APIAccountRepository?

    var body: some Scene {
        WindowGroup {
            Group {
                if clerk.user != nil {
                    if let accountRepository {
                        MainTabView(accountRepository: accountRepository)
                    }
                } else {
                    AuthView()
                }
            }
            .onChange(of: clerk.user != nil, initial: true) { _, isLoggedIn in
                if isLoggedIn, accountRepository == nil {
                    accountRepository = makeAccountRepository()
                }
            }
        }
        .environment(clerk)
    }

    private func makeAccountRepository() -> APIAccountRepository {
        let clerkRef = clerk
        return APIAccountRepository(
            apiClient: APIClient(
                baseURL: AppConfiguration.apiBaseURL,
                tokenProvider: { try await clerkRef.auth.getToken() }
            )
        )
    }
}
