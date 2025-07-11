//
//  AuthModels.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
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
