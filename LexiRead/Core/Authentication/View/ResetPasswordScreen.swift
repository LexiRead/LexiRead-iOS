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
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: BackButton())
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
