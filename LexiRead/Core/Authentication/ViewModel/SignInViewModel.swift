//
//  SignInViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 27/02/2025.
//


import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var agreedToTerms: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isSignupSuccessful: Bool = false
    @Published var navigateToLogin: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func validateInputs() -> Bool {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            showError = true
            return false
        }
        
        guard !email.isEmpty, email.isValidEmail else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        guard !passwordConfirmation.isEmpty else {
            errorMessage = "Please confirm your password"
            showError = true
            return false
        }
        
        guard password == passwordConfirmation else {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        guard agreedToTerms else {
            errorMessage = "You must agree to the Terms & Conditions"
            showError = true
            return false
        }
        
        return true
    }
    
    func signup() {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        // and simulate a successful registration
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            // Simulating network request for preview/testing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                
                self.isLoading = false
                
                // Simulate successful signup for testing
                if self.email.contains("@") && self.password.count >= 6 {
                    // Create a mock user for testing
                    let mockUser = User(id: 999, name: self.username, email: self.email, avatar: "", token: "mock-token-123")
                    UserManager.shared.saveUser(mockUser)
                    
                    // Show success alert
                    self.isSignupSuccessful = true
                } else {
                    self.errorMessage = "Failed to create account. Please try again."
                    self.showError = true
                }
            }
            return
        }
        #endif
        
        // Actual API call for production
        AuthService.shared.register(
            name: username,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation // Using the actual password confirmation field
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            
            if case .failure(let error) = completion {
                self.errorMessage = error.errorDescription ?? "Registration failed. Please try again."
                self.showError = true
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else { return }
            
            // Show success alert
            self.isSignupSuccessful = true
        }
        .store(in: &cancellables)
    }
}
