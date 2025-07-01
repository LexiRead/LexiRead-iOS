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




//
//  LoginViewModel.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var navigateToForgotPassword: Bool = false
    @Published var navigateToHome: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        !email.isEmpty && email.isValidEmail && !password.isEmpty
    }
    
    func login() {
        guard isFormValid else {
            errorMessage = "Please fill all required fields"
            showError = true
            return
        }
        
        isLoading = true
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        // and simulate a successful login. This is useful for UI testing.
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                
                // Simulate successful login for testing
                if self.email.contains("@") && self.password.count >= 6 {
                    // Create a mock user
                    let mockUser = User(id: 999, name: "Test User", email: self.email, avatar: "", token: "mock-token-123")
                    UserManager.shared.saveUser(mockUser)
                    
                    // Handle "remember me" functionality
                    if self.rememberMe {
                        UserDefaults.standard.set(self.email, forKey: UserDefaultKeys.savedEmail)
                        UserDefaults.standard.set(true, forKey: UserDefaultKeys.rememberMe)
                    } else {
                        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.savedEmail)
                        UserDefaults.standard.set(false, forKey: UserDefaultKeys.rememberMe)
                    }
                    
                    // Navigate to home screen
                    self.navigateToHome = true
                } else {
                    // Error
                    self.errorMessage = "Invalid email or password"
                    self.showError = true
                }
            }
            return
        }
        #endif
        
        // Actual API call for production
        AuthService.shared.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.errorDescription ?? "Login failed. Please try again."
                    self.showError = true
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                
                // If remember me is checked, we can save the email for future logins
                if self.rememberMe {
                    UserDefaults.standard.set(self.email, forKey: UserDefaultKeys.savedEmail)
                    UserDefaults.standard.set(true, forKey: UserDefaultKeys.rememberMe)
                } else {
                    UserDefaults.standard.removeObject(forKey: UserDefaultKeys.savedEmail)
                    UserDefaults.standard.set(false, forKey: UserDefaultKeys.rememberMe)
                }
                
                // Navigate to home screen
                self.navigateToHome = true
            }
            .store(in: &cancellables)
    }
    
    func checkSavedCredentials() {
        // Check if we have a saved email for "remember me" functionality
        if let savedEmail = UserDefaults.standard.string(forKey: UserDefaultKeys.savedEmail) {
            self.email = savedEmail
            self.rememberMe = UserDefaults.standard.bool(forKey: UserDefaultKeys.rememberMe)
        }
        
        // Note: We're intentionally NOT auto-navigating to home screen here,
        // even if the user is logged in, to allow for testing/demonstration of the login flow.
        // In a production app, you might want to uncomment the code below:
        
        
//         Check if user is already logged in
        if UserManager.shared.isLoggedIn {
            self.navigateToHome = true
        }
       
    }
}


// MARK: - Preview
#Preview {
    LoginScreen()
}




//
//  APIError.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case invalidData
    case invalidURL
    case networkError(String)
    case serverError(String)
    case authenticationError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server. Please try again."
        case .invalidData:
            return "Invalid data received from the server."
        case .invalidURL:
            return "Invalid URL. Please check the API endpoint."
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .authenticationError(let message):
            return "Authentication error: \(message)"
        case .unknown(let message):
            return message.isEmpty ? "An unknown error occurred." : message
        }
    }
    
    static func mapError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        if let nsError = error as NSError? {
            if let message = nsError.userInfo["message"] as? String {
                return .serverError(message)
            }
            
            switch nsError.code {
            case -1009:
                return .networkError("No internet connection")
            case 401, 403:
                return .authenticationError("Invalid credentials or session expired")
            case 500, 501, 502, 503:
                return .serverError("Server error. Please try again later.")
            default:
                return .unknown(nsError.localizedDescription)
            }
        }
        
        return .unknown(error.localizedDescription)
    }
}
