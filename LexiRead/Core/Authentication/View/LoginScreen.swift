//
//  LoginScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//


import SwiftUI

struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and App Name
            VStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 70)
                
                Text("LexiRead")
                    .font(.system(size: 36, weight: .bold))                
                    .foregroundColor(.darkerBlue)
            }
            .padding(.top, 60)
            
            // Title
            VStack(spacing: 16) {
                Text("Welcome Back!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary900)
                
                Text("Log in to get started")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
            }
            
            VStack(spacing: 20) {
                // Email Field
                LRTextField(
                    title: "Email",
                    placeholder: "bill.sanders@example.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )
                
                
                // Password Field
                LRTextField(
                    title: "Password",
                    placeholder: "Password",
                    text: $viewModel.password,
                    isSecure: true,
                    trailingIcon: Image(systemName: "eye.slash"),
                    trailingAction: {
                        // Password visibility is already handled by LRTextField
                    }
                )
            }
            .padding(.top, 20)
            
            // Remember me and Forgot Password
            
            HStack {
                Button(action: {
                    viewModel.rememberMe.toggle()
                }) {
                    HStack {
                        Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.rememberMe ? .darkerBlue : .gray)
                        
                        Text("Remember me")
                            .font(.subheadline)
                            .foregroundColor(.primary900)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.navigateToForgotPassword = true
                }) {
                    Text("Forget Password?")
                        .font(.subheadline)
                        .foregroundColor(.lrYellow)
                }
            }
            
            Spacer()
            
            // Login Button
            Button {
                viewModel.login()
            } label: {
                LRButton(title: "Log in", isPrimary: true)
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: BackButton())
        .padding(.horizontal)
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        )
        .navigationDestination(isPresented: $viewModel.navigateToForgotPassword) {
            ForgotPasswordScreen()
        }
        .navigationDestination(isPresented: $viewModel.navigateToHome) {
            MainTabView()
        }
        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    dismiss()
//                }) {
//                    Image(systemName: "arrow.left")
//                        .foregroundColor(.primary900)
//                }
//            }
//        }
        .alert("Login Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            viewModel.checkSavedCredentials()
        }
    }
}

// MARK: - Preview
#Preview {
    LoginScreen()
}






