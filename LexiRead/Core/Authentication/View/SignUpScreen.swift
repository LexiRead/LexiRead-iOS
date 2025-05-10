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
        .toolbarVisibility(.hidden)
    }
}

#Preview {
    SignUpScreen()
}


class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var agreedToTerms: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isSignupSuccessful: Bool = false
    @Published var navigateToLogin: Bool = false

    
    func validateInputs() -> Bool {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            showError = true
            return false
        }
        
        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        guard agreedToTerms else {
            errorMessage = "You must agree to the Terms & Conditions"
            showError = true
            return false
        }
        
        return true
    }
    
    func signup() {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        // Network call with Alamofire
        // 1. Prepare parameters
        let parameters: [String: Any] = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        // 2. Define API endpoint
        let signupURL = "https://api.lexiread.com/auth/register" // Replace with your actual API endpoint
        
        // 3. Alamofire implementation placeholder
        /*
        AF.request(signupURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: SignupResponse.self) { [weak self] response in
                guard let self = self else { return }
                
                self.isLoading = false
                
                switch response.result {
                case .success(let signupResponse):
                    // Handle successful signup
                    self.isSignupSuccessful = true
                    
                    // You might want to store user data or tokens here
                    // UserDefaults.standard.set(signupResponse.token, forKey: "userToken")
                    
                case .failure(let error):
                    // Handle error
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    
                    // For more specific error handling:
                    if let data = response.data, let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                        self.errorMessage = serverError.message
                    }
                }
            }
        */
        
        // Simulating network request for preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // Simulate successful signup for testing
            if self.email.contains("@") && self.password.count >= 6 {
                self.isSignupSuccessful = true
            } else {
                self.errorMessage = "Failed to create account. Please try again."
                self.showError = true
            }
        }
    }
}
