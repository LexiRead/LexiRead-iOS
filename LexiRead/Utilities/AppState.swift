//
//  AppState.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import Foundation



import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Check if user is already logged in
        isAuthenticated = UserManager.shared.isLoggedIn
    }
    
    func checkAuthStatus() {
        isAuthenticated = UserManager.shared.isLoggedIn
    }
    
    func logout() {
//        isLoading = true
//
//        AuthService.shared.logout()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] success in
//                guard let self = self else { return }
//                self.isLoading = false
//                if success {
//                    self.isAuthenticated = false
//                }
//            }
//            .store(in: &cancellables)
    }
}
