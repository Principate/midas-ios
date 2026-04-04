//
//  MainTabView.swift
//  Midas
//

import SwiftUI
import ClerkKitUI

struct MainTabView: View {
    
    let accountRepository: AccountRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let expenseRepository: ExpenseRepositoryProtocol
    @State private var selectedTab: AppTab = .portfolio
    @State private var showLogExpense = false
    
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
                NavigationStack {
                    CreateExpenseView(
                        viewModel: LogExpenseViewModel(
                            accountRepository: accountRepository,
                            expenseRepository: expenseRepository
                        )
                    )
                }
            }
            
        }
    }
    
}

#Preview {
    MainTabView(
        accountRepository: InMemoryAccountRepository(),
        categoryRepository: InMemoryCategoryRepository(),
        expenseRepository: InMemoryExpenseRepository()
    )
}
