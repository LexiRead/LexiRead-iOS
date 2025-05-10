////
////  DummyViewModel.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 25/02/2025.
////
//
//import Foundation
//import Alamofire
//
//class UserViewModel: ObservableObject {
//    @Published var users: [User] = [User(id: 1, name: "Atallah", email: "aratallah@gmail.com", profileImageURL: "string")]
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let baseURL = "https://api.example.com"
//    
//    func fetchUsers() {
//        isLoading = true
//        errorMessage = nil
//        
//        // Example of adding custom headers and parameters
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer YOUR_ACCESS_TOKEN",
//            "App-Version": "1.0.0"
//        ]
//        
//        let parameters: Parameters = [
//            "page": 1,
//            "limit": 20,
//            "sort": "name"
//        ]
//        
//        NetworkManager.shared.get(
//            url: "\(baseURL)/users",
//            parameters: parameters,
//            headers: headers
//        ) { [weak self] (result: Result<UserResponse, NetworkError>) in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                switch result {
//                case .success(let response):
//                    self?.users = response.users
//                    
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                    print("Error fetching users: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    func createUser(name: String, email: String, completion: @escaping (Bool) -> Void) {
//        isLoading = true
//        errorMessage = nil
//        
//        let parameters: Parameters = [
//            "name": name,
//            "email": email
//        ]
//        
//        NetworkManager.shared.post(
//            url: "\(baseURL)/users",
//            parameters: parameters
//        ) { [weak self] (result: Result<User, NetworkError>) in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                switch result {
//                case .success(let user):
//                    self?.users.append(user)
//                    completion(true)
//                    
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                    print("Error creating user: \(error.localizedDescription)")
//                    completion(false)
//                }
//            }
//        }
//    }
//}
