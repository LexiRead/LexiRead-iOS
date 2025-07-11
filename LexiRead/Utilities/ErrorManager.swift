//
//  ErrorManager.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 25/02/2025.
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
