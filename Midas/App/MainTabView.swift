//
//  MainTabView.swift
//  Midas
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .portfolio
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                tabContent
                tabBar
            }
            .background(.background)
            
            if selectedTab == .portfolio {
                floatingActionButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
            }
        }
    }
}

// MARK: - Tab Content

private extension MainTabView {
    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .portfolio:
            HomeView()
        case .allocations:
            AllocationsView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Floating Action Button

private extension MainTabView {
    var floatingActionButton: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color.cyan)
                .frame(width: 56, height: 56)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Tab Bar

private extension MainTabView {
    var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.cyan)
                .frame(height: 3)
            
            HStack {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Spacer()
                    
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 20))
                            
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .tracking(1)
                        }
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(.background)
        }
    }
}

#Preview {
    MainTabView()
}
