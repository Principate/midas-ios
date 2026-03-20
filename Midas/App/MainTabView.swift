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
                ProfileView()
            }
            
            Tab(
                AppTab.createExpense.title,
                systemImage: AppTab.createExpense.iconName,
                value: AppTab.createExpense,
                role:.search
            ) {
                Text("Create Expense")
            }

        }
    }
    
}

#Preview {
    MainTabView()
}
