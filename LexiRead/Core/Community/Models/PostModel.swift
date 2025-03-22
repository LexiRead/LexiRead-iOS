//
//  PostModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 22/03/2025.
//

import Foundation

struct Comment: Identifiable, Codable {
    var id: String
    var userFullName: String
    var content: String
    var timeAgo: String
    var userProfileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userFullName = "user_full_name"
        case content
        case timeAgo = "time_ago"
        case userProfileImage = "user_profile_image"
    }
}

// Models
struct Post: Identifiable, Codable {
    var id: String
    var userFullName: String
    var content: String
    var timeAgo: String
    var commentCount: Int
    var userProfileImage: String?
    var comments: [Comment]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userFullName = "user_full_name"
        case content
        case timeAgo = "time_ago"
        case commentCount = "comment_count"
        case userProfileImage = "user_profile_image"
        case comments
    }
}
