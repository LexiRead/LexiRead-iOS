//
//  ForgotPasswordViewModel.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Combine

class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var emailError: String?
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var navigateToOTPVerification: Bool = false
    @Published var alertMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func sendVerificationCode() {
        guard validateEmail() else { return }
        
        isLoading = true
        // Actual API call for production
        AuthService.shared.forgetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.showAlert = true
                    self.alertTitle = "Error"
                    self.alertMessage = error.errorDescription ?? "Failed to send verification code."
                }
            } receiveValue: { [weak self] message in
                guard let self = self else { return }
                
                // Store the email for the OTP verification screen
                UserDefaults.standard.set(self.email, forKey: "resetPasswordEmail")
                
                // Navigate to OTP screen directly without showing success alert
                self.navigateToOTPVerification = true
            }
            .store(in: &cancellables)
    }
    
    private func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            emailError = "Email is required"
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Email is required"
            return false
        }
        
        if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email"
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Please enter a valid email"
            return false
        }
        
        emailError = nil
        return true
    }
}
