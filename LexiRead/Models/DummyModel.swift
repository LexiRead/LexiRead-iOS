//
//  DummyModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 25/02/2025.
//

import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let profileImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profileImageURL = "profile_image_url"
    }
}

struct UserResponse: Codable {
    let users: [User]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case users
        case totalCount = "total_count"
    }
}
