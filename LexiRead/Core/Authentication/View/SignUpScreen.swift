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


//
//  SignUpViewModel.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

//
//  SignUpViewModel.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var agreedToTerms: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isSignupSuccessful: Bool = false
    @Published var navigateToLogin: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func validateInputs() -> Bool {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            showError = true
            return false
        }
        
        guard !email.isEmpty, email.isValidEmail else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        guard !passwordConfirmation.isEmpty else {
            errorMessage = "Please confirm your password"
            showError = true
            return false
        }
        
        guard password == passwordConfirmation else {
            errorMessage = "Passwords do not match"
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
        
        // For testing/demo purposes, you can use this block to bypass the actual API call
        // and simulate a successful registration
        #if DEBUG
        if ProcessInfo.processInfo.environment["UITESTING"] == "1" {
            // Simulating network request for preview/testing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                
                self.isLoading = false
                
                // Simulate successful signup for testing
                if self.email.contains("@") && self.password.count >= 6 {
                    // Create a mock user for testing
                    let mockUser = User(id: 999, name: self.username, email: self.email, avatar: "", token: "mock-token-123")
                    UserManager.shared.saveUser(mockUser)
                    
                    // Show success alert
                    self.isSignupSuccessful = true
                } else {
                    self.errorMessage = "Failed to create account. Please try again."
                    self.showError = true
                }
            }
            return
        }
        #endif
        
        // Actual API call for production
        AuthService.shared.register(
            name: username,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation // Using the actual password confirmation field
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            
            if case .failure(let error) = completion {
                self.errorMessage = error.errorDescription ?? "Registration failed. Please try again."
                self.showError = true
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else { return }
            
            // Show success alert
            self.isSignupSuccessful = true
        }
        .store(in: &cancellables)
    }
}



//MARK: - models
//
//  AuthModels.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let avatar: String
    let token: String
}

struct AuthResponse: Codable {
    let data: User
}

struct ServerErrorResponse: Codable {
    let message: String
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let password_confirmation: String
    let avatar: String
}

struct ForgetPasswordResponse: Codable {
    let data: String
}

struct VerifyOTPData: Codable {
    let message: String
    let reset_token: String
}

struct VerifyOTPResponse: Codable {
    let data: VerifyOTPData
}

struct ResendOTPResponse: Codable {
    let data: String
}

struct ResetPasswordResponse: Codable {
    let data: String
}


//  NetworkService.swift
//  LexiRead
//
//  Created on 12/05/2025.
//


//  NetworkService.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

//  NetworkService.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Alamofire

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func register(name: String, email: String, password: String, passwordConfirmation: String, avatar: String = "", completion: @escaping (Result<User, Error>) -> Void) {
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "avatar": avatar
        ]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.register, parameters: parameters, requiresAuth: false) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let authResponse):
                completion(.success(authResponse.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.login, parameters: parameters, requiresAuth: false) { (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let authResponse):
                completion(.success(authResponse.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func forgetPassword(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "email": email
        ]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.forgetPassword, parameters: parameters, requiresAuth: false) { (result: Result<ForgetPasswordResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func verifyOtp(email: String, code: String, completion: @escaping (Result<VerifyOTPData, Error>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "code": code
        ]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.verifyOtp, parameters: parameters, requiresAuth: false) { (result: Result<VerifyOTPResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func resetPassword(resetToken: String, email: String, password: String, passwordConfirmation: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "reset_token": resetToken,
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.resetPassword, parameters: parameters, requiresAuth: false) { (result: Result<ResetPasswordResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func resendOtp(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "email": email
        ]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.resendOtp, parameters: parameters, requiresAuth: false) { (result: Result<ResendOTPResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}



//
//  UserManager.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var isLoggedIn: Bool {
        return token != nil
    }
    
    var token: String? {
        return UserDefaults.standard.string(forKey: UserDefaultKeys.token)
    }
    
    var userId: Int? {
        return UserDefaults.standard.integer(forKey: UserDefaultKeys.userId)
    }
    
    var userName: String? {
        return UserDefaults.standard.string(forKey: UserDefaultKeys.userName)
    }
    
    var userEmail: String? {
        return UserDefaults.standard.string(forKey: UserDefaultKeys.userEmail)
    }
    
    var userAvatar: String? {
        return UserDefaults.standard.string(forKey: UserDefaultKeys.userAvatar)
    }
    
    func saveUser(_ user: User) {
        UserDefaults.standard.set(user.token, forKey: UserDefaultKeys.token)
        UserDefaults.standard.set(user.id, forKey: UserDefaultKeys.userId)
        UserDefaults.standard.set(user.name, forKey: UserDefaultKeys.userName)
        UserDefaults.standard.set(user.email, forKey: UserDefaultKeys.userEmail)
        UserDefaults.standard.set(user.avatar, forKey: UserDefaultKeys.userAvatar)
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.token)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.userId)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.userName)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.userEmail)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.userAvatar)
    }
}



//
//  AuthService.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

//
//  AuthService.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

//
//  AuthService.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // Login with email and password
    func login(email: String, password: String) -> AnyPublisher<User, APIError> {
        return Future<User, APIError> { promise in
            NetworkService.shared.login(email: email, password: password) { result in
                switch result {
                case .success(let user):
                    // Save user data
                    UserManager.shared.saveUser(user)
                    promise(.success(user))
                    
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Register a new user
    func register(name: String, email: String, password: String, passwordConfirmation: String, avatar: String = "") -> AnyPublisher<User, APIError> {
        return Future<User, APIError> { promise in
            NetworkService.shared.register(
                name: name,
                email: email,
                password: password,
                passwordConfirmation: passwordConfirmation,
                avatar: avatar
            ) { result in
                switch result {
                case .success(let user):
                    // Save user data
                    UserManager.shared.saveUser(user)
                    promise(.success(user))
                    
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Send forget password request
    func forgetPassword(email: String) -> AnyPublisher<String, APIError> {
        return Future<String, APIError> { promise in
            NetworkService.shared.forgetPassword(email: email) { result in
                switch result {
                case .success(let message):
                    promise(.success(message))
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Verify OTP code
    func verifyOtp(email: String, code: String) -> AnyPublisher<VerifyOTPData, APIError> {
        return Future<VerifyOTPData, APIError> { promise in
            NetworkService.shared.verifyOtp(email: email, code: code) { result in
                switch result {
                case .success(let data):
                    promise(.success(data))
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Reset password
    func resetPassword(resetToken: String, email: String, password: String, passwordConfirmation: String) -> AnyPublisher<String, APIError> {
        return Future<String, APIError> { promise in
            NetworkService.shared.resetPassword(resetToken: resetToken, email: email, password: password, passwordConfirmation: passwordConfirmation) { result in
                switch result {
                case .success(let message):
                    promise(.success(message))
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Resend OTP code
    func resendOtp(email: String) -> AnyPublisher<String, APIError> {
        return Future<String, APIError> { promise in
            NetworkService.shared.resendOtp(email: email) { result in
                switch result {
                case .success(let message):
                    promise(.success(message))
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Logout the current user
    func logout() -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
//            UserManager.shared.logout { success in
//                promise(.success(success))
//            }
        }
        .eraseToAnyPublisher()
    }
    
    // Check if user is logged in
    var isLoggedIn: Bool {
        return UserManager.shared.isLoggedIn
    }
    
    // Get current user info
    var currentUser: (id: Int?, name: String?, email: String?, avatar: String?, token: String?) {
        return (
            UserManager.shared.userId,
            UserManager.shared.userName,
            UserManager.shared.userEmail,
            UserManager.shared.userAvatar,
            UserManager.shared.token
        )
    }
}



//
//  NetworkManager.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    let baseURL = APIConstants.baseURL
    
    private init() {}
    
    // Headers for authenticated requests
    func authHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = UserManager.shared.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    // General GET request
    func get<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil, requiresAuth: Bool = true, completion: @escaping (Result<T, Error>) -> Void) {
        let url = "\(baseURL)/\(endpoint)"
        let headers: HTTPHeaders = requiresAuth ? authHeaders() : ["Accept": "application/json"]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let serverError = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                            completion(.failure(NSError(domain: "NetworkError", code: response.response?.statusCode ?? 0, userInfo: ["message": serverError.message])))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // General POST request
    func post<T: Decodable>(endpoint: String, parameters: [String: Any], requiresAuth: Bool = true, completion: @escaping (Result<T, Error>) -> Void) {
        let url = "\(baseURL)/\(endpoint)"
        let headers: HTTPHeaders = requiresAuth ? authHeaders() : ["Accept": "application/json"]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let serverError = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                            completion(.failure(NSError(domain: "NetworkError", code: response.response?.statusCode ?? 0, userInfo: ["message": serverError.message])))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // General PUT request
    func put<T: Decodable>(endpoint: String, parameters: [String: Any], requiresAuth: Bool = true, completion: @escaping (Result<T, Error>) -> Void) {
        let url = "\(baseURL)/\(endpoint)"
        let headers: HTTPHeaders = requiresAuth ? authHeaders() : ["Accept": "application/json"]
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let serverError = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                            completion(.failure(NSError(domain: "NetworkError", code: response.response?.statusCode ?? 0, userInfo: ["message": serverError.message])))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // General DELETE request
    func delete<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil, requiresAuth: Bool = true, completion: @escaping (Result<T, Error>) -> Void) {
        let url = "\(baseURL)/\(endpoint)"
        let headers: HTTPHeaders = requiresAuth ? authHeaders() : ["Accept": "application/json"]
        
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let serverError = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                            completion(.failure(NSError(domain: "NetworkError", code: response.response?.statusCode ?? 0, userInfo: ["message": serverError.message])))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
}



//
//  AppState.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Check if user is already logged in
        isAuthenticated = UserManager.shared.isLoggedIn
    }
    
    func checkAuthStatus() {
        isAuthenticated = UserManager.shared.isLoggedIn
    }
    
    func logout() {
//        isLoading = true
//        
//        AuthService.shared.logout()
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] success in
//                guard let self = self else { return }
//                self.isLoading = false
//                if success {
//                    self.isAuthenticated = false
//                }
//            }
//            .store(in: &cancellables)
    }
}








//MARK: - constants

//
//  Constants.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

//
//  Constants.swift
//  LexiRead
//
//  Created on 12/05/2025.
//

import Foundation
import SwiftUI

// MARK: - API Constants
struct APIConstants {
    static let baseURL = "http://app.elfar5a.com/api"
    
    struct Endpoints {
        static let login = "auth/login"
        static let register = "auth/register"
        static let forgetPassword = "auth/forgetPassword"
        static let verifyOtp = "auth/verifyOtp"
        static let resendOtp = "auth/resendotp"
        static let resetPassword = "auth/resetPassword"
        static let updateProfile = "auth/update-profile"
    }
}

// MARK: - User Default Keys
struct UserDefaultKeys {
    static let token = "userToken"
    static let userId = "userId"
    static let userName = "userName"
    static let userEmail = "userEmail"
    static let userAvatar = "userAvatar"
    static let savedEmail = "savedEmail"
    static let rememberMe = "rememberMe"
}

// MARK: - SwiftUI Color Extensions
//extension Color {
//    static let primary900 = Color("primary900")
//    static let darkerBlue = Color("darkerBlue")
//    static let lrYellow = Color("lrYellow")
//}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

