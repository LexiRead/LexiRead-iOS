//
//  TabBarView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 23/04/2025.
//

import SwiftUI


// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Books Tab
            BooksScreen()
                .tabItem {
                    Image("book")
                        .renderingMode(.template)
                    Text("Books")
                }
                .tag(0)
            
            // Translate Tab
            TranslateScreen()
                .tabItem {
                    Image("translate")
                        .renderingMode(.template)
                    Text("Translate")
                }
                .tag(1)
            
            // Word List Tab
            WordListScreen()
                .tabItem {
                    Image("WordListIcon")
                        .renderingMode(.template)
                    Text("Word List")
                }
                .tag(2)
            
            // Community Tab
            CommunityScreen()
                .tabItem {
                    Image("community")
                        .renderingMode(.template)
                    Text("Community")
                }
                .tag(3)
            
            // More Tab
            MoreScreen()
                .tabItem {
                    Image("MoreIcon")
                        .renderingMode(.template)
                    Text("More")
                }
                .tag(4)
        }
        .onAppear {
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                
                // Set colors for normal state
                let normalAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(.gray.opacity(6))
                ]
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(.gray.opacity(6))
                
                // Set colors for selected state
                let selectedAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor(.darkerBlue)
                ]
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(.darkerBlue)
                
                // Apply the appearance
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            } else {
                // Fallback for iOS 14 and earlier
                let unselectedColor = UIColor(Color("primary900"))
                UITabBar.appearance().unselectedItemTintColor = unselectedColor
                
                let selectedColor = UIColor(Color("main"))
                UITabBar.appearance().tintColor = selectedColor
            }
            
            // Optional: customize the tab bar background
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    }
}

#Preview {
    MainTabView()
}

