//
//  Network Manager .swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 17/02/2025.
//

import Alamofire
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // Configurable session manager
    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        return Session(configuration: configuration)
    }()
    
    // Generic request function for any endpoint and model type
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Convert our HTTPMethod to Alamofire's HTTPMethod
        let afMethod = Alamofire.HTTPMethod(rawValue: method.rawValue)
        
        // Create default headers if none provided
        let finalHeaders: HTTPHeaders = headers ?? [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.request(
            url,
            method: afMethod,
            parameters: parameters,
            encoding: encoding,
            headers: finalHeaders
        ).validate().responseData { response in
            switch response.result {
            case .success(let data):
                // Check if we have data
                guard !data.isEmpty else {
                    completion(.failure(.noData))
                    return
                }
                
                // Attempt to decode the data to our expected type
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
                
            case .failure(let error):
                // Handle different errors
                if let statusCode = response.response?.statusCode {
                    let message = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                    completion(.failure(.serverError(statusCode: statusCode, message: message)))
                } else {
                    completion(.failure(.networkFailure(error)))
                }
            }
        }
    }
    
    // Convenience method for making GET requests
    func get<T: Decodable>(
        url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .get,
            parameters: parameters,
            headers: headers,
            completion: completion
        )
    }
    
    // Convenience method for making POST requests
    func post<T: Decodable>(
        url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .post,
            parameters: parameters,
            headers: headers,
            encoding: encoding,
            completion: completion
        )
    }
    
    // Convenience method for making PUT requests
    func put<T: Decodable>(
        url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .put,
            parameters: parameters,
            headers: headers,
            encoding: encoding,
            completion: completion
        )
    }
    
    // Convenience method for making DELETE requests
    func delete<T: Decodable>(
        url: String,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        request(
            url: url,
            method: .delete,
            parameters: parameters,
            headers: headers,
            completion: completion
        )
    }
}
