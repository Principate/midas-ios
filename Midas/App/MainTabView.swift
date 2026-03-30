//
//  MainTabView.swift
//  Midas
//

import SwiftUI
import ClerkKitUI

struct MainTabView: View {

    let accountRepository: AccountRepositoryProtocol
    @State private var selectedTab: AppTab = .portfolio

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab(
                AppTab.portfolio.title,
                systemImage: AppTab.portfolio.iconName,
                value: AppTab.portfolio
            ) {
                HomeView(accountRepository: accountRepository)
            }

            Tab(
                AppTab.accounts.title,
                systemImage: AppTab.accounts.iconName,
                value: AppTab.accounts
            ) {
                AccountsView(accountRepository: accountRepository)
            }

            Tab(
                AppTab.profile.title,
                systemImage: AppTab.profile.iconName,
                value: AppTab.profile,
            ) {
                UserProfileView()
            }

            Tab(
                AppTab.createExpense.title,
                systemImage: AppTab.createExpense.iconName,
                value: AppTab.createExpense,
                role: .search
            ) {
                Text("Create Expense")
            }

        }
    }

}

#Preview {
    MainTabView(accountRepository: InMemoryAccountRepository())
}
