//
//  SignInViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 27/02/2025.
//

import Foundation


//class SignupViewModel: ObservableObject {
//    @Published var username: String = ""
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var agreedToTerms: Bool = false
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String = ""
//    @Published var isSignupSuccessful: Bool = false
//    
//    // Reference to network manager (would be injected in production code)
//    // private let networkManager: NetworkManager
//    
//    // init(networkManager: NetworkManager) {
//    //     self.networkManager = networkManager
//    // }
//    
//    func validateInputs() -> Bool {
//        guard !username.isEmpty else {
//            errorMessage = "Username cannot be empty"
//            return false
//        }
//        
//        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
//            errorMessage = "Please enter a valid email address"
//            return false
//        }
//        
//        guard password.count >= 6 else {
//            errorMessage = "Password must be at least 6 characters"
//            return false
//        }
//        
//        guard agreedToTerms else {
//            errorMessage = "You must agree to the Terms & Conditions"
//            return false
//        }
//        
//        return true
//    }
//    
//    func signup() {
//        guard validateInputs() else { return }
//        
//        isLoading = true
//        errorMessage = ""
//        
//        let credentials = UserCredentials(
//            username: username,
//            email: email,
//            password: password
//        )
//        
//        // PLACEHOLDER: Network Manager Call
//        // Replace this placeholder with your actual NetworkManager implementation
//        
//        // Example of how the NetworkManager would be called:
//        /*
//        networkManager.request(
//            endpoint: .signup,
//            method: .post,
//            parameters: credentials
//        ) { [weak self] (result: Result<SignupResponse, NetworkError>) in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                switch result {
//                case .success(let response):
//                    self.isSignupSuccessful = true
//                    // Handle success (store token, etc.)
//                    
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//        */
//        
//        // Simulating network call for preview purposes
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//            guard let self = self else { return }
//            self.isLoading = false
//            self.isSignupSuccessful = true
//        }
//    }
//}


//struct UserCredentials: Encodable {
//    let username: String
//    let email: String
//    let password: String
//}
//struct SignupResponse: Decodable {
//    let success: Bool
//    let message: String
//    let token: String?
//}
//
