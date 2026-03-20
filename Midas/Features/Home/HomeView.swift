//
//  HomeView.swift
//  Midas
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(accountRepository: AccountRepositoryProtocol) {
        _viewModel = State(initialValue: HomeViewModel(accountRepository: accountRepository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    netWorthHeader
                    accountsSection
                }
            }
            .onAppear {
                if viewModel.accounts.isEmpty {
                    viewModel.loadAccounts()
                }
            }
        }
    }
}

// MARK: - Net Worth Header

private extension HomeView {
    var netWorthHeader: some View {
        VStack(spacing: 8) {
            Spacer()
                .frame(height: 24)

            Text("NET WORTH")
                .font(.caption)
                .tracking(3)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(viewModel.formattedNetWorth.whole)
                    .font(.system(size: 48, weight: .regular, design: .serif))
                    .foregroundStyle(.primary)

                Text(viewModel.formattedNetWorth.decimal)
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary)
            }

            Text("Base Currency: USD")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
                .frame(height: 24)

            Divider()
        }
    }
}

// MARK: - Accounts Section

private extension HomeView {
    var accountsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ACTIVE ACCOUNTS")
                .font(.caption)
                .tracking(2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            ForEach(viewModel.accounts) { account in
                accountRow(account)

                if account.id != viewModel.accounts.last?.id {
                    Divider()
                        .padding(.leading, 20)
                }
            }
        }
    }

    func accountRow(_ account: Account) -> some View {
        HStack(spacing: 16) {
            accountIcon(for: account)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(account.formattedSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.formattedBalance(for: account))
                    .font(.title3)
                    .fontDesign(.serif)

                if let usdEquivalent = viewModel.formattedUSDEquivalent(for: account) {
                    Text(usdEquivalent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    func accountIcon(for account: Account) -> some View {
        let isFilled = account.iconType == .bank

        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isFilled ? Color.black : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: isFilled ? 0 : 1)
                )
                .frame(width: 48, height: 48)

            Image(systemName: account.iconType.systemImageName)
                .font(.system(size: 20))
                .foregroundStyle(isFilled ? .white : .primary)
        }
    }
}

#Preview {
    HomeView(accountRepository: InMemoryAccountRepository())
}
