////
////  PostDetailViewModel.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 22/03/2025.
////
//
//import Foundation
//
//class PostDetailViewModel: ObservableObject {
//    @Published var comments: [Comment] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    private let postId: String
//    private let commentsEndpoint: String
//    private let postCommentEndpoint: String
//    
//    init(postId: String) {
//        
//        self.postId = postId
//        self.commentsEndpoint = "YOUR_API_URL/posts/\(postId)/comments"
//        self.postCommentEndpoint = "YOUR_API_URL/posts/\(postId)/comment"
//        
//        // For demo/preview purposes, load sample data
//        self.loadSampleData()
//    }
//    
//    func fetchComments() {
//       
//    }
//    
//    func postComment(content: String) {
//        
//        
//        // For demo purposes, add a mock comment
//        let newComment = Comment(
//            id: UUID().uuidString,
//            userFullName: "Current User",
//            content: content,
//            timeAgo: "Just now",
//            userProfileImage: nil
//        )
//        
//        self.comments.insert(newComment, at: 0)
//    }
//    
//    // Sample data for development and preview
//    private func loadSampleData() {
//        comments = [
//            Comment(id: "1", userFullName: "Jane Cooper", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg gw s", timeAgo: "45 minutes ago", userProfileImage: nil),
//            Comment(id: "2", userFullName: "Cameron Williamson", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg gw s", timeAgo: "45 minutes ago", userProfileImage: nil),
//            Comment(id: "3", userFullName: "Leslie Alexander", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg gw s", timeAgo: "45 minutes ago", userProfileImage: nil)
//        ]
//    }
//}
