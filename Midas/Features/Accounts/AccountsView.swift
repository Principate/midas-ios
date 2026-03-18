//
//  AccountsView.swift
//  Midas
//

import SwiftUI

struct AccountsView: View {
    let accountRepository: AccountRepositoryProtocol
    @State private var isShowingCreateAccount = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    accountsList
                }
                .padding(.horizontal, 20)
            }
            .overlay(alignment: .bottomTrailing) {
                createAccountButton
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.navigationStack)
            .fullScreenCover(isPresented: $isShowingCreateAccount) {
                CreateAccountView(accountRepository: accountRepository)
            }
        }
    }
}

// MARK: - Header

private extension AccountsView {
    var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Existing Accounts")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .italic()

            Spacer()

            Text("TOTAL: \(accountRepository.accounts.count)")
                .font(.caption)
                .tracking(2)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Accounts List

private extension AccountsView {
    var accountsList: some View {
        VStack(spacing: 0) {
            ForEach(accountRepository.accounts) { account in
                accountRow(account)

                Divider()
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
        }
    }

    func accountRow(_ account: Account) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.system(size: 20, weight: .regular, design: .serif))

                Text(account.formattedSubtitle)
                    .font(.caption2)
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 16))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 18)
    }
}

// MARK: - Create Account Section

private extension AccountsView {
    var createAccountButton: some View {
        Button(action: { isShowingCreateAccount = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.brandDarkGreen)
                .clipShape(Circle())
                .shadow(color: Color.brandDarkGreen.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}

#Preview {
    let repository = InMemoryAccountRepository()
    repository.loadInitialAccounts()
    return AccountsView(accountRepository: repository)
}
