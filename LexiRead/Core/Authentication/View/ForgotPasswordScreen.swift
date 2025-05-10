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

// MARK: - ForgotPasswordViewModel
class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var emailError: String?
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var navigateToOTPVerification: Bool = false
    @Published var alertMessage: String = ""
    
    private let networkManager = NetworkManager.shared
    
    func sendVerificationCode() {
//        guard validateEmail() else { return }
//        
//        isLoading = true
//        
//        // API call placeholder using Alamofire
//        networkManager.sendForgotPasswordRequest(email: email) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                switch result {
//                case .success:
//                    // Navigate to OTP verification screen
//                    // You'll need to implement this navigation
//                    break
//                    
//                case .failure(let error):
//                    self?.showAlert = true
//                    self?.alertTitle = "Error"
//                    self?.alertMessage = error.localizedDescription
//                }
//            }
//        }
        self.navigateToOTPVerification = true
    }
    
    private func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            emailError = "Email is required"
            return false
        }
        
        if !emailPredicate.evaluate(with: email) {
            emailError = "Please enter a valid email"
            return false
        }
        
        emailError = nil
        return true
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
