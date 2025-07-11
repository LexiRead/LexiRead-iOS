





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
