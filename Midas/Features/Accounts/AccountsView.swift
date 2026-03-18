//
//  AccountsView.swift
//  Midas
//

import SwiftUI

struct AccountsView: View {
    let accountRepository: AccountRepositoryProtocol
    @State private var isShowingCreateAccount = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Accounts")
                .font(.title2)
                .fontWeight(.medium)

            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: { isShowingCreateAccount = true }) {
                Text("Add Account")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.cyan)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isShowingCreateAccount) {
            CreateAccountView(accountRepository: accountRepository)
        }
    }
}

#Preview {
    AccountsView(accountRepository: InMemoryAccountRepository())
}
