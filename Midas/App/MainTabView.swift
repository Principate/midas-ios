//
//  MainTabView.swift
//  Midas
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .portfolio
    @State private var accountRepository = InMemoryAccountRepository()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.portfolio.title, systemImage: AppTab.portfolio.iconName, value: .portfolio) {
                HomeView(accountRepository: accountRepository)
            }

            Tab(AppTab.accounts.title, systemImage: AppTab.accounts.iconName, value: .accounts) {
                AccountsView(accountRepository: accountRepository)
            }

            Tab(AppTab.profile.title, systemImage: AppTab.profile.iconName, value: .profile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
