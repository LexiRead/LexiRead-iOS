//
//  APIConstant.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import Foundation



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
