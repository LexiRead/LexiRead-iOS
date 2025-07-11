//
//  ResetPasswordScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import SwiftUI


import Foundation
import Combine

class ResetPasswordViewModel: ObservableObject {
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var newPasswordError: String?
    @Published var confirmPasswordError: String?
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var navigateToHome: Bool = false
    
    private var resetToken: String = ""
    private var email: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Get the reset token and email from UserDefaults
        self.resetToken = UserDefaults.standard.string(forKey: "resetToken") ?? ""
        self.email = UserDefaults.standard.string(forKey: "resetPasswordEmail") ?? ""
    }
    
    func saveNewPassword() {
        guard validatePasswords() else { return }
        
        isLoading = true
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                
                // Simulate successful password reset for testing
                self.showAlert = true
                self.alertTitle = "Success"
                self.alertMessage = "Password reset successfully"
                
                // Navigate to home screen after alert is dismissed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigateToHome = true
                }
            }
            return
        }
        #endif
        
        // Actual API call for production
        AuthService.shared.resetPassword(resetToken: resetToken, email: email, password: newPassword, passwordConfirmation: confirmPassword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.showAlert = true
                    self.alertTitle = "Error"
                    self.alertMessage = error.errorDescription ?? "Failed to reset password."
                }
            } receiveValue: { [weak self] message in
                guard let self = self else { return }
                
                // Show success message
                self.showAlert = true
                self.alertTitle = "Success"
                self.alertMessage = message
                
                // Clear saved reset token and email
                UserDefaults.standard.removeObject(forKey: "resetToken")
                UserDefaults.standard.removeObject(forKey: "resetPasswordEmail")
                
                // Navigate to home screen after alert is dismissed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigateToHome = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func validatePasswords() -> Bool {
        // Reset previous errors
        newPasswordError = nil
        confirmPasswordError = nil
        
        if newPassword.isEmpty {
            newPasswordError = "New password is required"
            showAlert = true
            alertTitle = "Error"
            alertMessage = "New password is required"
            return false
        }
        
        if newPassword.count < 6 {
            newPasswordError = "Password must be at least 6 characters"
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Password must be at least 6 characters"
            return false
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordError = "Confirm password is required"
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Confirm password is required"
            return false
        }
        
        if newPassword != confirmPassword {
            confirmPasswordError = "Passwords do not match"
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Passwords do not match"
            return false
        }
        
        if resetToken.isEmpty {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Reset token is missing. Please try the forgot password process again."
            return false
        }
        
        if email.isEmpty {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Email is missing. Please try the forgot password process again."
            return false
        }
        
        return true
    }
}

