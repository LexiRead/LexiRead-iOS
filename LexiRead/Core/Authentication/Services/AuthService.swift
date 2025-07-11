//
//  AuthService.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
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
