//
//  LoginViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var navigateToForgotPassword: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        !email.isEmpty && email.isValidEmail && !password.isEmpty
    }
    
    func login() {
        guard isFormValid else {
            errorMessage = "Please fill all required fields"
            showError = true
            return
        }
        
        isLoading = true
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        // and simulate a successful login. This is useful for UI testing.
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                
                // Simulate successful login for testing
                if self.email.contains("@") && self.password.count >= 6 {
                    // Create a mock user
                    let mockUser = User(id: 999, name: "Test User", email: self.email, avatar: "", token: "mock-token-123")
                    UserManager.shared.saveUser(mockUser)
                    
                    // Handle "remember me" functionality
                    if self.rememberMe {
                        UserDefaults.standard.set(self.email, forKey: UserDefaultKeys.savedEmail)
                        UserDefaults.standard.set(true, forKey: UserDefaultKeys.rememberMe)
                    } else {
                        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.savedEmail)
                        UserDefaults.standard.set(false, forKey: UserDefaultKeys.rememberMe)
                    }
                    
                    // Navigate to home screen
                    self.navigateToHome = true
                } else {
                    // Error
                    self.errorMessage = "Invalid email or password"
                    self.showError = true
                }
            }
            return
        }
        #endif
        
        // Actual API call for production
        AuthService.shared.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.errorDescription ?? "Login failed. Please try again."
                    self.showError = true
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                
                // If remember me is checked, we can save the email for future logins
                if self.rememberMe {
                    UserDefaults.standard.set(self.email, forKey: UserDefaultKeys.savedEmail)
                    UserDefaults.standard.set(true, forKey: UserDefaultKeys.rememberMe)
                } else {
                    UserDefaults.standard.removeObject(forKey: UserDefaultKeys.savedEmail)
                    UserDefaults.standard.set(false, forKey: UserDefaultKeys.rememberMe)
                }
                
                // Navigate to home screen
                self.navigateToHome = true
            }
            .store(in: &cancellables)
    }
    
    func checkSavedCredentials() {
        // Check if we have a saved email for "remember me" functionality
        if let savedEmail = UserDefaults.standard.string(forKey: UserDefaultKeys.savedEmail) {
            self.email = savedEmail
            self.rememberMe = UserDefaults.standard.bool(forKey: UserDefaultKeys.rememberMe)
        }
        
        // Note: We're intentionally NOT auto-navigating to home screen here,
        // even if the user is logged in, to allow for testing/demonstration of the login flow.
        // In a production app, you might want to uncomment the code below:
        
        
//         Check if user is already logged in
        if UserManager.shared.isLoggedIn {
            self.navigateToHome = true
        }
       
    }
}
