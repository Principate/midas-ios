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
    @State private var hasLoadedAccounts = false
    @State private var startupLoadError: String?

    var body: some Scene {
        WindowGroup {
            Group {
                if clerk.user != nil {
                    if let accountRepository {
                        if hasLoadedAccounts {
                            MainTabView(accountRepository: accountRepository)
                        } else {
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Loading accounts…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    AuthView()
                }
            }
            .alert(
                "Couldn't load accounts",
                isPresented: Binding(
                    get: { startupLoadError != nil },
                    set: { if !$0 { startupLoadError = nil } }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(startupLoadError ?? "")
            }
            .onChange(of: clerk.user != nil, initial: true) { _, isLoggedIn in
                if isLoggedIn {
                    if accountRepository == nil {
                        let repo = makeAccountRepository()
                        accountRepository = repo
                        hasLoadedAccounts = false
                        Task { @MainActor in
                            defer { hasLoadedAccounts = true }
                            do {
                                try await repo.loadInitialAccounts()
                            } catch {
                                startupLoadError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            }
                        }
                    }
                } else {
                    // Signed out: clear state
                    accountRepository = nil
                    hasLoadedAccounts = false
                    startupLoadError = nil
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

