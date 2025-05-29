//
//  ForgotPasswordScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/05/2025.
//

import SwiftUI

// MARK: - ForgotPasswordView
//
//  ForgotPasswordScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/05/2025.
//

import SwiftUI

// MARK: - ForgotPasswordView
struct ForgotPasswordScreen: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
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
                    
                    Text("LixeRead")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.darkerBlue))
                }

                
                VStack(spacing: 16){
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
            
            // Email Input
            
                LRTextField(
                    title: "Email",
                    placeholder: "tim.jennings@example.com",
                    text: $viewModel.email
                )
            
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Send Verification Button
            Button {
                viewModel.sendVerificationCode()
            } label: {
                LRButton(title: "Send Verification Code", isPrimary: true)
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
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        )
        .navigationDestination(isPresented: $viewModel.navigateToOTPVerification) {
            OTPVerificationScreen()
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

// MARK: - BackButton Component
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary900)
                .imageScale(.large)
        }
    }
}

#Preview {
    ForgotPasswordScreen()
}


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
        
//        // For testing/demo purposes, you can use this block to bypass the actual API call
//        #if DEBUG
//        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//                guard let self = self else { return }
//                self.isLoading = false
//                
//                // Simulate successful OTP send for testing
//                if self.email.contains("@") {
//                    // Store email for OTP verification screen
//                    UserDefaults.standard.set(self.email, forKey: "resetPasswordEmail")
//                    // Navigate to OTP screen directly
//                    self.navigateToOTPVerification = true
//                } else {
//                    self.showAlert = true
//                    self.alertTitle = "Error"
//                    self.alertMessage = "Failed to send verification code. Please check your email and try again."
//                }
//            }
//            return
//        }
//        #endif
        
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

#Preview {
    ForgotPasswordScreen()
}
