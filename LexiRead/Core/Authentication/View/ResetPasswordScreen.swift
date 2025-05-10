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

// MARK: - ViewModel
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

    
    private let networkManager = NetworkManager.shared
    
    func saveNewPassword() {
//        guard validatePasswords() else { return }
        
        isLoading = true
        
        // API call placeholder using Alamofire
        // networkManager.resetPassword(newPassword: newPassword) { [weak self] result in
        //     DispatchQueue.main.async {
        //         self?.isLoading = false
        //         switch result {
        //         case .success:
        //             // Navigate to login screen or home screen
        //             break
        //         case .failure(let error):
        //             self?.showAlert = true
        //             self?.alertTitle = "Error"
        //             self?.alertMessage = error.localizedDescription
        //         }
        //     }
        // }
        self.navigateToHome = true
    }
    
    private func validatePasswords() -> Bool {
        // Reset previous errors
        newPasswordError = nil
        confirmPasswordError = nil
        
        // Password validation rules
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        if newPassword.isEmpty {
            newPasswordError = "New password is required"
            return false
        }
        
        if !passwordPredicate.evaluate(with: newPassword) {
            newPasswordError = "Password must contain at least 8 characters, including uppercase, lowercase, and numbers"
            return false
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordError = "Confirm password is required"
            return false
        }
        
        if newPassword != confirmPassword {
            confirmPasswordError = "Passwords do not match"
            return false
        }
        
        return true
    }
}


#Preview {
    ResetPasswordScreen()
}
