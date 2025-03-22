//
//  LexiReadApp.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 10/02/2025.
//

import SwiftUI

@main
struct LexiReadApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CommunityScreen()
                    .navigationBarHidden(true)
            }
        }
    }
}
