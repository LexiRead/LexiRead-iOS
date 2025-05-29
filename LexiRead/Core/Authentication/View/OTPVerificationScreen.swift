//
//  OTPVerificationScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/05/2025.
//

import SwiftUI

struct OTPVerificationScreen: View {
    @StateObject private var viewModel = OTPVerificationViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Focus states for each field
    @FocusState private var focusField1: Bool
    @FocusState private var focusField2: Bool
    @FocusState private var focusField3: Bool
    @FocusState private var focusField4: Bool
    
    var body: some View {
        VStack(spacing: 8) {
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
                    Text("Forget Password")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary900)
                    
                    Text("We will send you an OTP code via email, please enter it to confirm the transaction.")
                        .font(.system(size: 14))
                        .foregroundColor(.lrGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 50)
            
            // OTP Input Fields
            HStack(spacing: 16) {
                OTPTextField(text: $viewModel.otpDigits[0])
                    .focused($focusField1)
                    .onChange(of: viewModel.otpDigits[0]) { newValue in
                        if newValue.count == 1 { focusField2 = true }
                    }
                
                OTPTextField(text: $viewModel.otpDigits[1])
                    .focused($focusField2)
                    .onChange(of: viewModel.otpDigits[1]) { newValue in
                        if newValue.count == 1 { focusField3 = true }
                    }
                
                OTPTextField(text: $viewModel.otpDigits[2])
                    .focused($focusField3)
                    .onChange(of: viewModel.otpDigits[2]) { newValue in
                        if newValue.count == 1 { focusField4 = true }
                    }
                
                OTPTextField(text: $viewModel.otpDigits[3])
                    .focused($focusField4)
            }
            .padding(.horizontal, 24)
            
            // Resend Option
            HStack(spacing: 4) {
                Text("The code was not sent?")
                    .foregroundColor(.primary900)
                
                Button(action: viewModel.resendCode) {
                    Text("Resend it")
                        .foregroundColor(.lrYellow)
                }
            }
            .font(.system(size: 14))
            .padding(.top, 16)
            
            Spacer()
            
            // Confirmation Button
            Button(action: {
                viewModel.verifyOTP()
            }, label: {
                LRButton(
                    title: "Confirm",
                    isPrimary: true
                )
            })
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
        .navigationDestination(isPresented: $viewModel.navigateToResetPasswordScreen) {
            ResetPasswordScreen()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            focusField1 = true
        }
    }
}


#Preview {
    OTPVerificationScreen()
}

// MARK: - ViewModel
//
//  OTPVerificationViewModel.swift
//  LexiRead
//
//  Created on 12/05/2025.
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

#Preview {
    OTPVerificationScreen()
}


// MARK: - OTP TextField
struct OTPTextField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 80, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary900, lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
            }
    }
}
