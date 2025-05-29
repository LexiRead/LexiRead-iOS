//
//  ResetPasswordScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/05/2025.
//

import SwiftUI

struct ResetPasswordScreen: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            // Title Section
            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text("LexiRead")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.darkerBlue))
                }
                
                VStack(spacing: 16) {
                    Text("Secure Your Account")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary900)
                    
                    Text("Enter a new password for lixeread account")
                        .font(.system(size: 14))
                        .foregroundColor(.lrGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 50)
            
            // Password Fields
            VStack(spacing: 24) {
                LRTextField(
                    title: "New Password",
                    placeholder: "Password",
                    text: $viewModel.newPassword,
                    isSecure: true,
                    trailingIcon: Image(systemName: "eye.slash")
                )
                
                LRTextField(
                    title: "Confirm New Password",
                    placeholder: "Confirm Password",
                    text: $viewModel.confirmPassword,
                    isSecure: true,
                    trailingIcon: Image(systemName: "eye.slash")
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Save Button
            Button {
                viewModel.saveNewPassword()
            } label: {
                LRButton(title: "Save New Password", isPrimary: true)
            }

           
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: BackButton {
//            presentationMode.wrappedValue.dismiss()
//        })
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        )
        .navigationDestination(isPresented: $viewModel.navigateToHome) {
            MainTabView()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    ResetPasswordScreen()
}
// MARK: - ViewModel
//
//  ResetPasswordViewModel.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

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

#Preview {
    ResetPasswordScreen()
}
