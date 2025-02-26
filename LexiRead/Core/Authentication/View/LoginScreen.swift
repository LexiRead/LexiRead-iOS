//
//  LoginScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import SwiftUI

struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 70)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .padding()
                
                Text("LixeRead")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            // Welcome Back text
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("Welcome Back!")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("👋")
                        .font(.system(size: 24))
                }
                
                Text("Log in to get started")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
            }
            .padding(.bottom, 20)
            
            // Email field
            VStack(spacing: 16) {
                LRTextField(
                    title: "Email",
                    placeholder: "bill.sanders@example.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )
                
                
                // Password field
                LRTextField(
                    title: "Password",
                    placeholder: "Password",
                    text: $viewModel.password,
                    isSecure: true,
                    trailingIcon: Image(systemName: viewModel.password.isEmpty ? "eye.slash" : "eye.slash.fill")
                )
            }
            .padding(.horizontal)
            // Remember me and Forgot Password
            HStack {
                // Remember me checkbox
                Toggle("", isOn: $viewModel.rememberMe)
                    .labelsHidden()
                    .toggleStyle(CheckboxToggleStyle())
                
                Text("Remember me")
                    .font(.system(size: 14))
                    .foregroundColor(Color.black)
                
                Spacer()
                
                // Forgot Password button
                Button(action: {
                    viewModel.forgotPassword()
                }) {
                    Text("Forget Password?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(UIColor.systemYellow))
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Login Button
            PrimaryButton(title: "Log in", action: {
                viewModel.login()
            })
            .padding(.horizontal, 24)
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .toolbarVisibility(.hidden)
    }
}

#Preview {
    LoginScreen()
}
