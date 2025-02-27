//
//  SignUPView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 27/02/2025.
//

import SwiftUI

struct SignUPScreen: View {
    @StateObject private var viewModel = SignupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Logo and Header
                VStack(spacing: 8) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text("LixeRead")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)))
                }
                    VStack(spacing: 16) {
                        Text("Join Lixeread Today ✨")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        
                        Text("sign up for a new account")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                
                .padding(.bottom, 20)
                
                // Form Fields
                VStack(alignment: .leading, spacing: 8) {
                    
                    LRTextField(title: "Username", placeholder: "Robert Fox", text: $viewModel.username)
                    
                    LRTextField(title: "Email" , placeholder: "tim.jennings@example.com", text: $viewModel.email)
                    
                    LRTextField(
                        title: "Password",
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecure: true,
                        trailingIcon: Image(systemName: viewModel.password.isEmpty ? "eye.slash" : "eye.slash.fill")
                    )
                    
                }
                
                // Terms and Conditions
                Toggle(isOn: $viewModel.agreedToTerms) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("I agree to lixeread")
                            
                            Button(action: {
                                // Open Terms & Conditions
                            }) {
                                Text("Terms & Conditions")
                                    .foregroundColor(Color(UIColor(red: 0.94, green: 0.64, blue: 0.18, alpha: 1.0)))
                            }
                        }
                    }
                }
                .padding(.trailing,40)
                .toggleStyle(CheckboxToggleStyle())
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
               
                NavigationLink {
                    LoginScreen()
                } label: {
                    TextButton(title: "Sign Up")
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
            }
            .padding()
        }
        .alert(isPresented: $viewModel.isSignupSuccessful) {
            Alert(
                title: Text("Signup Successful"),
                message: Text("Your account has been created."),
                dismissButton: .default(Text("OK")) {
                    // Navigate to home screen or login screen
                }
            )
        }
        .toolbarVisibility(.hidden)
    }
}

#Preview {
    SignUPScreen()
}
