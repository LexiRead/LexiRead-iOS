//
//  SignUPView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 27/02/2025.
//
import SwiftUI

struct SignUpScreen: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo and Header
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
                
                
                VStack(spacing: 16) {
                    Text("Join Lixeread Today")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        .foregroundColor(Color(.primary900))
                    
                    
                    Text("sign up for a new account")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                .padding(.bottom, 20)
                
                // Form Fields
                VStack(alignment: .leading, spacing: 16) {
                    
                    LRTextField(title: "Username", placeholder: "Robert Fox", text: $viewModel.username)
                    
                    LRTextField(title: "Email" , placeholder: "tim.jennings@example.com", text: $viewModel.email)
                    
                    LRTextField(
                        title: "Password",
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecure: true,
                        trailingIcon: Image(systemName: viewModel.password.isEmpty ? "eye.slash" : "eye.slash.fill")
                    )
                    
                    LRTextField(
                        title: "Confirm Password",
                        placeholder: "Confirm Password",
                        text: $viewModel.passwordConfirmation,
                        isSecure: true,
                        trailingIcon: Image(systemName: viewModel.passwordConfirmation.isEmpty ? "eye.slash" : "eye.slash.fill")
                    )
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Button(action: {
                            viewModel.agreedToTerms.toggle()
                        }) {
                            HStack {
                                Image(systemName: viewModel.agreedToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.agreedToTerms ? .darkerBlue : .gray)
                                
                                Text("I agree to lixeread")
                                    .foregroundColor(Color(.primary900))
                                
                                Button(action: {
                                    // Open Terms & Conditions
                                }) {
                                    Text("Terms & Conditions")
                                        .foregroundColor(Color(.lrYellow))
                                }
                                
                            }
                        }
                    }
                }
                
                // Login Link
                HStack {
                    Text("Aleady have an account?")
                        .foregroundColor(.gray)
                    
                    NavigationLink {
                        LoginScreen()
                    } label: {
                        Text("Login")
                            .fontWeight(.bold)
                            .foregroundColor(Color(UIColor(red: 0.94, green: 0.64, blue: 0.18, alpha: 1.0)))
                    }
                    
                }
                .padding(.top, 10)
                Button {
                    viewModel.signup()
                } label: {
                    LRButton(title: "Sign Up", isPrimary: true)
                }
                .padding(.bottom)
                
            }
            .padding()
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
        .alert(isPresented: $viewModel.isSignupSuccessful) {
            Alert(
                title: Text("Signup Successful"),
                message: Text("Your account has been created."),
                dismissButton: .default(Text("OK")) {
                    viewModel.navigateToLogin = true
                }
            )
        }
        .navigationDestination(isPresented: $viewModel.navigateToLogin) {
            LoginScreen()
        }
    }
}

#Preview {
    SignUpScreen()
}
