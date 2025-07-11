//
//  UserManager.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import Foundation


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

