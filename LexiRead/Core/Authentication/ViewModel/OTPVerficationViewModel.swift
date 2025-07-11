//
//  OTPVerficationViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//


import Foundation
import Combine

class OTPVerificationViewModel: ObservableObject {
    @Published var otpDigits: [String] = Array(repeating: "", count: 4)
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var navigateToResetPasswordScreen: Bool = false
    
    private var email: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Get the email from UserDefaults that was stored during the forgot password flow
        self.email = UserDefaults.standard.string(forKey: "resetPasswordEmail") ?? ""
    }
    
    var otp: String {
        otpDigits.joined()
    }
    
    func verifyOTP() {
        guard otp.count == 4 else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Please enter the complete OTP code"
            return
        }
        
        isLoading = true
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                
                // Simulate successful OTP verification for testing
                if self.otp == "1234" {
                    // Store a mock reset token
                    UserDefaults.standard.set("mock-reset-token", forKey: "resetToken")
                    self.navigateToResetPasswordScreen = true
                } else {
                    self.showAlert = true
                    self.alertTitle = "Error"
                    self.alertMessage = "Invalid OTP code. Please try again."
                }
            }
            return
        }
        #endif
        
        // Actual API call for production
        verifyOtpCode(email: email, code: otp)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.showAlert = true
                    self.alertTitle = "Error"
                    self.alertMessage = error.errorDescription ?? "Failed to verify OTP code."
                }
            } receiveValue: { [weak self] verifyData in
                guard let self = self else { return }
                
                // Store the reset token for the password reset screen
                UserDefaults.standard.set(verifyData.reset_token, forKey: "resetToken")
                
                // Navigate to reset password screen
                self.navigateToResetPasswordScreen = true
            }
            .store(in: &cancellables)
    }
    
    func resendCode() {
        guard !email.isEmpty else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "No email found for resending OTP. Please go back to the forgot password screen."
            return
        }
        
        isLoading = true
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                
                // Simulate successful OTP resend for testing
                self.otpDigits = Array(repeating: "", count: 4) // Clear current OTP
                
                self.showAlert = true
                self.alertTitle = "Success"
                self.alertMessage = "A new OTP has been sent to your email."
            }
            return
        }
        #endif
        
        // Actual API call for production
        AuthService.shared.resendOtp(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.showAlert = true
                    self.alertTitle = "Error"
                    self.alertMessage = error.errorDescription ?? "Failed to resend OTP code."
                }
            } receiveValue: { [weak self] message in
                guard let self = self else { return }
                
                // Clear current OTP
                self.otpDigits = Array(repeating: "", count: 4)
                
                // Show success message
                self.showAlert = true
                self.alertTitle = "Success"
                self.alertMessage = message
            }
            .store(in: &cancellables)
    }
    
    private func verifyOtpCode(email: String, code: String) -> AnyPublisher<VerifyOTPData, APIError> {
        return AuthService.shared.verifyOtp(email: email, code: code)
    }
}
