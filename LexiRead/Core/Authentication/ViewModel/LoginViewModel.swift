//
//  LoginViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var showingAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading: Bool = false
    
    
    func login() {
        guard !email.isEmpty else {
            showAlert("Please enter your email")
            return
        }
        
        guard !password.isEmpty else {
            showAlert("Please enter your password")
            return
        }
        
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            // This is where you would integrate with your authentication service
            if self.isValidCredentials() {
                // Handle successful login - save user, navigate, etc.
                print("Login successful for: \(self.email)")
            } else {
                self.showAlert("Invalid email or password")
            }
        }
    }
    
    func forgotPassword() {
        guard !email.isEmpty else {
            showAlert("Please enter your email first")
            return
        }
        
        // Implement password reset logic
//        showAlert("Password reset email sent to \(email)")
    }
    
    private func isValidCredentials() -> Bool {
        // This is a simple validation - replace with actual authentication logic
        return email.contains("@") && password.count >= 6
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}
