//
//  AccountsView.swift
//  Midas
//

import SwiftUI

struct AccountsView: View {
    let accountRepository: AccountRepositoryProtocol
    @State private var isShowingCreateAccount = false
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool

    private var filteredAccounts: [Account] {
        guard !searchText.isEmpty else {
            return accountRepository.accounts
        }
        let query = searchText.lowercased()
        return accountRepository.accounts.filter { account in
            account.name.lowercased().contains(query)
                || account.accountType.displayName.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            header
            ScrollView {
                accountsList
                    .padding(.horizontal, 20)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    createAccountButton
                }
            }
            .toolbarRole(.automatic)
            .fullScreenCover(isPresented: $isShowingCreateAccount) {
                CreateAccountView(accountRepository: accountRepository)
            }
        }
    }
}

// MARK: - Header

extension AccountsView {
    fileprivate var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Existing Accounts")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .italic()

            Spacer()

            Text("TOTAL: \(filteredAccounts.count)")
                .font(.caption)
                .tracking(2)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Accounts List

extension AccountsView {
    fileprivate var accountsList: some View {
        VStack(spacing: 0) {
            ForEach(filteredAccounts) { account in
                accountRow(account)

                Divider()
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
        }
    }

    fileprivate func accountRow(_ account: Account) -> some View {
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

extension AccountsView {
    fileprivate var createAccountButton: some View {
        Button(action: { isShowingCreateAccount = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    AccountsView(accountRepository: InMemoryAccountRepository())
}
