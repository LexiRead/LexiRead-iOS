////
////  CommunityViewModel.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 22/03/2025.
////
//
//import Foundation
//
//class CommunityViewModel: ObservableObject {
//    @Published var forYouPosts: [Post] = []
//    @Published var myPosts: [Post] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    private let forYouEndpoint = "YOUR_API_URL/for_you"
//    private let myPostsEndpoint = "YOUR_API_URL/my_posts"
//    
//    func fetchForYouPosts() {
//        self.loadSampleData()
//        
//    }
//    
//    func fetchMyPosts() {
//      
//    }
//    
//    // Sample data for development and preview
//    private func loadSampleData() {
//        forYouPosts = [
//            Post(id: "1", userFullName: "Wade Warren", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil),
//            Post(id: "2", userFullName: "Bessie Cooper", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil),
//            Post(id: "3", userFullName: "Bessie Cooper", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil)
//        ]
//    }
//    
//    
//    func deletePost(postId: String) {
//        // In a real app, this would call an API
//        // For now, we'll just remove it from the local array
//        myPosts.removeAll { $0.id == postId }
//    }
//    
//    
//    func addPost(content: String) {
//        // In a real app, you would make an API call
//        let newPost = Post(
//            id: UUID().uuidString,
//            userFullName: "Guy Hawkins",
//            content: content,
//            timeAgo: "Just now",
//            commentCount: 0,
//            userProfileImage: nil
//        )
//        
//        myPosts.insert(newPost, at: 0)
//    }
//}
