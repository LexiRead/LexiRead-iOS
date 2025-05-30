

// Models used in the Community feature

import Foundation

// MARK: - Community Models

struct Post: Identifiable, Codable {
    let id: String
    let userFullName: String
    let content: String
    let timeAgo: String
    let commentCount: Int
    let userProfileImage: String?
    let isLiked: Bool
    let canEdit: Bool
    let image: String?
}

struct Comment: Identifiable, Codable {
    let id: String
    let userFullName: String
    let content: String
    let timeAgo: String
    let userProfileImage: String?
}

// MARK: - API Response Models

// Pagination metadata
struct PaginationLinks: Codable {
    let first: String?
    let last: String?
    let prev: String?
    let next: String?
}

struct PaginationMeta: Codable {
    let current_page: Int
    let from: Int?
    let last_page: Int
    let links: [PaginationLink]?
    let path: String
    let per_page: Int
    let to: Int?
    let total: Int
    
    struct PaginationLink: Codable {
        let url: String?
        let label: String
        let active: Bool
    }
}

// Post Response Models with pagination
struct PaginatedPostsResponse: Codable {
    struct Data: Codable {
        let data: [PostData]
        let links: PaginationLinks
        let meta: PaginationMeta
    }
    
    let data: Data
}

// Single Post Response
struct SinglePostResponse: Codable {
    let data: PostData
}

struct PostData: Codable {
    let id: Int
    let content: String
    let user: UserData
    let image: String
    let likes_count: Int
    let comments_count: Int
    let is_liked: Bool
    let can_edit: Bool
    let created_at: String
}

// Create Post Response
struct CreatePostResponse: Codable {
    struct Data: Codable {
        let message: String
        let post: PostData
    }
    
    let data: Data
}

// Comments Response with pagination
struct PaginatedCommentsResponse: Codable {
    struct Data: Codable {
        let data: [CommentData]
        let links: PaginationLinks
        let meta: PaginationMeta
    }
    
    let data: Data
}

// Create Comment Response
struct CreateCommentResponse: Codable {
    struct Data: Codable {
        let message: String
        let comment: CommentData
    }
    
    let data: Data
}

struct CommentData: Codable {
    let id: Int
    let content: String
    let user: UserData
    let created_at: String
    let post_id: Int?
    let can_edit: Bool?
}

// User Data
struct UserData: Codable {
    let id: Int
    let name: String
    let avatar: String
}





// Community API Service Implementation

import Foundation
import Combine
import UIKit

class CommunityService {
    static let shared = CommunityService()
    
    private init() {}
    
    private let baseURL = APIConstants.baseURL
    
    // MARK: - Fetch Community Posts (For You)
    func fetchCommunityPosts() -> AnyPublisher<[Post], APIError> {
        return NetworkManager.shared.get(endpoint: "/community/posts", requiresAuth: true)
            .map { (response: PaginatedPostsResponse) -> [Post] in
                return response.data.data.map { postData in
                    Post(
                        id: String(postData.id),
                        userFullName: postData.user.name,
                        content: postData.content,
                        timeAgo: postData.created_at,
                        commentCount: postData.comments_count,
                        userProfileImage: postData.user.avatar.isEmpty ? nil : postData.user.avatar,
                        isLiked: postData.is_liked,
                        canEdit: postData.can_edit,
                        image: postData.image.isEmpty ? nil : postData.image
                    )
                }
            }
            .mapError { APIError.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch My Posts
    func fetchMyPosts() -> AnyPublisher<[Post], APIError> {
        return NetworkManager.shared.get(endpoint: "/community/user/posts", requiresAuth: true)
            .map { (response: PaginatedPostsResponse) -> [Post] in
                return response.data.data.map { postData in
                    Post(
                        id: String(postData.id),
                        userFullName: postData.user.name,
                        content: postData.content,
                        timeAgo: postData.created_at,
                        commentCount: postData.comments_count,
                        userProfileImage: postData.user.avatar.isEmpty ? nil : postData.user.avatar,
                        isLiked: postData.is_liked,
                        canEdit: postData.can_edit,
                        image: postData.image.isEmpty ? nil : postData.image
                    )
                }
            }
            .mapError { APIError.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Create Post
    func createPost(content: String) -> AnyPublisher<Post, APIError> {
        let parameters: [String: Any] = ["content": content]
        
        return NetworkManager.shared.post(endpoint: "/community/posts", parameters: parameters, requiresAuth: true)
            .map { (response: CreatePostResponse) -> Post in
                let postData = response.data.post
                return Post(
                    id: String(postData.id),
                    userFullName: postData.user.name,
                    content: postData.content,
                    timeAgo: postData.created_at,
                    commentCount: postData.comments_count,
                    userProfileImage: postData.user.avatar.isEmpty ? nil : postData.user.avatar,
                    isLiked: postData.is_liked,
                    canEdit: postData.can_edit,
                    image: postData.image.isEmpty ? nil : postData.image
                )
            }
            .mapError { APIError.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Create Post with Image
    func createPostWithImage(content: String, imageData: Data) -> AnyPublisher<Post, APIError> {
        guard let url = URL(string: baseURL + "/community/posts") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Generate a unique boundary string
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Prepare the body of the request
        var body = Data()
        
        // Add content field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"content\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(content)\r\n".data(using: .utf8)!)
        
        // Add image field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End the request body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Log request in debug mode
        logNetworkRequest(request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log response for debugging
                logNetworkResponse(data: data, response: response, error: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    return data
                } else if httpResponse.statusCode == 401 {
                    throw APIError.authenticationError("Authentication failed")
                } else {
                    // Try to parse server error message
                    if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                        throw APIError.serverError(serverError.message)
                    } else {
                        throw APIError.serverError("Server error with status code: \(httpResponse.statusCode)")
                    }
                }
            }
            .decode(type: CreatePostResponse.self, decoder: JSONDecoder())
            .map { response -> Post in
                let postData = response.data.post
                return Post(
                    id: String(postData.id),
                    userFullName: postData.user.name,
                    content: postData.content,
                    timeAgo: postData.created_at,
                    commentCount: postData.comments_count,
                    userProfileImage: postData.user.avatar.isEmpty ? nil : postData.user.avatar,
                    isLiked: postData.is_liked,
                    canEdit: postData.can_edit,
                    image: postData.image.isEmpty ? nil : postData.image
                )
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else if let _ = error as? DecodingError {
                    return APIError.invalidData
                } else {
                    return APIError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Post
    func deletePost(postId: String) -> AnyPublisher<Bool, APIError> {
        return NetworkManager.shared.delete(endpoint: "/community/posts/\(postId)", requiresAuth: true)
            .map { (_: EmptyResponse) -> Bool in
                return true
            }
            .mapError { APIError.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Post Comments
    func fetchPostComments(postId: String) -> AnyPublisher<[Comment], APIError> {
        return NetworkManager.shared.get(endpoint: "/community/posts/\(postId)/comments", requiresAuth: true)
            .map { (response: PaginatedCommentsResponse) -> [Comment] in
                return response.data.data.map { commentData in
                    Comment(
                        id: String(commentData.id),
                        userFullName: commentData.user.name,
                        content: commentData.content,
                        timeAgo: commentData.created_at,
                        userProfileImage: commentData.user.avatar.isEmpty ? nil : commentData.user.avatar
                    )
                }
            }
            .mapError { APIError.mapError($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Post Comment
    func postComment(postId: String, content: String) -> AnyPublisher<Comment, APIError> {
        let parameters: [String: Any] = ["content": content]
        
        return NetworkManager.shared.post(endpoint: "/community/posts/\(postId)/comments", parameters: parameters, requiresAuth: true)
            .map { (response: CreateCommentResponse) -> Comment in
                let commentData = response.data.comment
                return Comment(
                    id: String(commentData.id),
                    userFullName: commentData.user.name,
                    content: commentData.content,
                    timeAgo: commentData.created_at,
                    userProfileImage: commentData.user.avatar.isEmpty ? nil : commentData.user.avatar
                )
            }
            .mapError { APIError.mapError($0) }
            .eraseToAnyPublisher()
    }
}

// Helper extension for multipart form data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


// Empty response struct for endpoints that don't return data
struct EmptyResponse: Codable {}


// ViewModels for Community Feature

// ViewModels for Community Feature

import Foundation
import Combine
import SwiftUI

// MARK: - CommunityViewModel
class CommunityViewModel: ObservableObject {
    @Published var forYouPosts: [Post] = []
    @Published var myPosts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchForYouPosts() {
        isLoading = true
        errorMessage = nil
        
        CommunityService.shared.fetchCommunityPosts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Error fetching for you posts: \(error)")
                }
            } receiveValue: { [weak self] posts in
                guard let self = self else { return }
                self.forYouPosts = posts
                if posts.isEmpty {
                    self.errorMessage = "No posts available"
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchMyPosts() {
        isLoading = true
        errorMessage = nil
        
        CommunityService.shared.fetchMyPosts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    print("Error fetching my posts: \(error)")
                }
            } receiveValue: { [weak self] posts in
                guard let self = self else { return }
                self.myPosts = posts
                if posts.isEmpty {
                    self.errorMessage = "No posts available"
                }
            }
            .store(in: &cancellables)
    }
    
    func deletePost(postId: String) {
        isLoading = true
        errorMessage = nil
        
        CommunityService.shared.deletePost(postId: postId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to delete post: \(error.localizedDescription)"
                    print("Error deleting post: \(error)")
                }
            } receiveValue: { [weak self] success in
                guard let self = self, success else { return }
                // Remove post from local array
                self.myPosts.removeAll { $0.id == postId }
            }
            .store(in: &cancellables)
    }
    
    func addPost(content: String) {
        isLoading = true
        errorMessage = nil
        
        CommunityService.shared.createPost(content: content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to create post: \(error.localizedDescription)"
                    print("Error creating post: \(error)")
                }
            } receiveValue: { [weak self] post in
                guard let self = self else { return }
                // Add new post to the top of the list
                self.myPosts.insert(post, at: 0)
            }
            .store(in: &cancellables)
    }
    
    func addPostWithImage(content: String, image: UIImage) {
        isLoading = true
        errorMessage = nil
        
        guard let imageData = image.compressForUpload() else {
            self.errorMessage = "Failed to process image"
            self.isLoading = false
            return
        }
        
        CommunityService.shared.createPostWithImage(content: content, imageData: imageData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to create post: \(error.localizedDescription)"
                    print("Error creating post with image: \(error)")
                }
            } receiveValue: { [weak self] post in
                guard let self = self else { return }
                // Add new post to the top of the list
                self.myPosts.insert(post, at: 0)
            }
            .store(in: &cancellables)
    }
}

// MARK: - PostDetailViewModel
class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let postId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(postId: String) {
        self.postId = postId
    }
    
    func fetchComments() {
        isLoading = true
        errorMessage = nil
        
        CommunityService.shared.fetchPostComments(postId: postId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                    print("Error fetching comments: \(error)")
                }
            } receiveValue: { [weak self] comments in
                guard let self = self else { return }
                self.comments = comments
                if comments.isEmpty {
                    self.errorMessage = "No comments yet"
                }
            }
            .store(in: &cancellables)
    }
    
    func postComment(content: String) {
        isLoading = true
        errorMessage = nil
        
        CommunityService.shared.postComment(postId: postId, content: content)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
                    print("Error posting comment: \(error)")
                }
            } receiveValue: { [weak self] comment in
                guard let self = self else { return }
                // Add new comment to the top of the list
                self.comments.insert(comment, at: 0)
            }
            .store(in: &cancellables)
    }
}

//// UI Components for Community Feature
//
//import SwiftUI
//
//// MARK: - TabButton
//struct TabButton: View {
//    let text: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    private let appBlueColor = Color.primary900
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Text(text)
//                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
//                    .foregroundColor(isSelected ? appBlueColor : .gray)
//                
//                // Indicator line
//                Rectangle()
//                    .fill(isSelected ? appBlueColor : Color.clear)
//                    .frame(height: 3)
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//}

// MARK: - PostCell
struct PostCell: View {
    let post: Post
    
    private let appBlueColor = Color.primary900
    
    var body: some View {
        NavigationLink(destination: PostDetailView(post: post)) {
            VStack(alignment: .leading, spacing: 0) {
                // Post header with user info
                HStack {
                    // Profile image
                    if let imageUrl = post.userProfileImage, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(post.userFullName.prefix(1)))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text(post.userFullName)
                            .font(.headline)
                        
                        HStack {
                            Text("Shared a")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Post")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        Text(post.timeAgo)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Three dots menu
                    Menu {
                        Button("Report", action: {})
                        Button("Share", action: {})
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.title3)
                            .foregroundColor(appBlueColor)
                    }
                }
                .padding()
                
                // Post content
                Text(post.content)
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Post image if available
                if let imageUrl = post.image, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 200)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                    }
                    .padding(.bottom, 8)
                }
                
                // Comments count
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.gray)
                    
                    Text("\(post.commentCount) Comments")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                Divider()
            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - MyPostCell
struct MyPostCell: View {
    let post: Post
    let onDeleteTap: () -> Void
    
    private let appBlueColor = Color.primary900
    
    var body: some View {
        NavigationLink(destination: PostDetailView(post: post)) {
            VStack(alignment: .leading, spacing: 0) {
                // Post header with user info
                HStack {
                    // Profile image
                    if let imageUrl = post.userProfileImage, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(post.userFullName.prefix(1)))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text(post.userFullName)
                            .font(.headline)
                        
                        HStack {
                            Text("Shared a")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Post")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        Text(post.timeAgo)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Delete button
                    Button(action: onDeleteTap) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 8)
                }
                .padding()
                
                // Post content
                Text(post.content)
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Post image if available
                if let imageUrl = post.image, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 200)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                    }
                    .padding(.bottom, 8)
                }
                
                // Comments count
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.gray)
                    
                    Text("\(post.commentCount) Comments")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                Divider()
            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - CommentCell
struct CommentCell: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Profile image
                if let imageUrl = comment.userProfileImage, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(comment.userFullName.prefix(1)))
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.userFullName)
                        .font(.headline)
                    
                    Text(comment.content)
                        .font(.body)
                    
                    Text(comment.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
        }
        .padding(.horizontal)
    }
}



//
//
////
////  MyPostCell.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 22/03/2025.
////


import SwiftUI
import Combine
import PhotosUI

// MARK: - CommunityScreen
struct CommunityScreen: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = CommunityViewModel()
    private let appBlueColor = Color.primary900
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Navigation bar
                customNavigationBar
                
                // Tab Navigation
                tabNavigationBar
                
                // Content area based on selected tab
                if selectedTab == 0 {
                    forYouContent
                } else {
                    MyPostsView()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchForYouPosts()
            }
        }
    }
    
    private var customNavigationBar: some View {
        Text("Community")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(appBlueColor)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var tabNavigationBar: some View {
        HStack(spacing: 0) {
            TabButton(text: "For You", isSelected: selectedTab == 0) {
                selectedTab = 0
                if viewModel.forYouPosts.isEmpty {
                    viewModel.fetchForYouPosts()
                }
            }
            
            TabButton(text: "My Posts", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
    }
    
    private var forYouContent: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.forYouPosts.isEmpty {
                ProgressView()
                    .padding()
            } else if let errorMessage = viewModel.errorMessage, viewModel.forYouPosts.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.forYouPosts.isEmpty {
                Text("No posts available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.forYouPosts) { post in
                        PostCell(post: post)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .refreshable {
            viewModel.fetchForYouPosts()
        }
    }
}

// MARK: - MyPostsView
struct MyPostsView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showingDeleteAlert = false
    @State private var postToDelete: Post?
    @State private var newPostText: String = ""
    @State private var showingPostSheet = false
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    
    private let appBlueColor = Color.primary900
    
    var body: some View {
        VStack(spacing: 0) {
            // "What's on your mind?" text field
            HStack(spacing: 12) {
                // User profile image
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(UserManager.shared.userName?.prefix(1) ?? "U")
                            .foregroundColor(.gray)
                    )
                
                // Text field that opens post creation when tapped
                Button(action: {
                    showingPostSheet = true
                }) {
                    HStack {
                        Text("What's on your mind?")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .frame(height: 40)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // Posts list
            ScrollView {
                if viewModel.isLoading && viewModel.myPosts.isEmpty {
                    ProgressView()
                        .padding()
                } else if let errorMessage = viewModel.errorMessage, viewModel.myPosts.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.myPosts.isEmpty {
                    Text("You haven't posted anything yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.myPosts) { post in
                            MyPostCell(post: post, onDeleteTap: {
                                postToDelete = post
                                showingDeleteAlert = true
                            })
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .refreshable {
            viewModel.fetchMyPosts()
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Post"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let post = postToDelete {
                        // Call delete function
                        viewModel.deletePost(postId: post.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showImagePicker){
            ImagePicker(selectedImage: $selectedImage, isPresented: $showImagePicker)
        }
        .sheet(isPresented: $showingPostSheet) {
            // Post creation sheet
            CreatePostView(
                showingPostSheet: $showingPostSheet,
                newPostText: $newPostText,
                selectedImage: $selectedImage,
                showImagePicker: $showImagePicker,
                viewModel: viewModel
            )
        }
        .onAppear {
            viewModel.fetchMyPosts()
        }
    }
}

// MARK: - CreatePostView
struct CreatePostView: View {
    @Binding var showingPostSheet: Bool
    @Binding var newPostText: String
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @ObservedObject var viewModel: CommunityViewModel
    
    private let appBlueColor = Color.primary900
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with cancel and post buttons
            HStack {
                Button("Cancel") {
                    showingPostSheet = false
                    selectedImage = nil
                    newPostText = ""
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                Text("Create Post")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("Post") {
                    if !newPostText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // Create new post using the API
                        if let image = selectedImage {
                            viewModel.addPostWithImage(content: newPostText, image: image)
                        } else {
                            viewModel.addPost(content: newPostText)
                        }
                        newPostText = ""
                        selectedImage = nil
                        showingPostSheet = false
                    }
                }
                .foregroundColor(appBlueColor)
                .disabled(newPostText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            
            Divider()
            
            // User info
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(UserManager.shared.userName?.prefix(1) ?? "U")
                            .foregroundColor(.gray)
                    )
                
                Text(UserManager.shared.userName ?? "User")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            // Text editor for post content
            TextEditor(text: $newPostText)
                .frame(minHeight: 120)
                .padding()
                .background(Color.white)
            
            // Selected image preview
            if let image = selectedImage {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 22))
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 8)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
            }
            
            // Add image button
            Button(action: {
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo")
                        .foregroundColor(appBlueColor)
                    
                    Text("Add Photo")
                        .foregroundColor(appBlueColor)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            Spacer()
        }
    }
}

// MARK: - PostDetailView
struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel: PostDetailViewModel
    @State private var commentText: String = ""
    private let appBlueColor = Color.primary900
    
    init(post: Post) {
        self.post = post
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(postId: post.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Post content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Post header with user info
                    HStack {
                        // Profile image
                        if let imageUrl = post.userProfileImage, !imageUrl.isEmpty {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(post.userFullName.prefix(1)))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text(post.userFullName)
                                .font(.headline)
                            
                            HStack {
                                Text("Shared a")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("Post")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            
                            Text(post.timeAgo)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Three dots menu
                        Menu {
                            Button("Report", action: {})
                            Button("Share", action: {})
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .font(.title3)
                                .foregroundColor(appBlueColor)
                        }
                    }
                    .padding()
                    
                    // Post content
                    Text(post.content)
                        .font(.body)
                        .padding()
                    
                    // Post image if available
                    if let imageUrl = post.image, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 200)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                        }
                        .padding(.bottom, 8)
                    }
                    
                    Divider()
                    
                    // Comments section header
                    Text("Comments")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if viewModel.comments.isEmpty {
                        Text("No comments yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Comments list
                        ForEach(viewModel.comments) { comment in
                            CommentCell(comment: comment)
                                .padding(.top, 8)
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            
            // Comment input area at the bottom
            HStack(spacing: 10) {
                // Current user profile image
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(UserManager.shared.userName?.prefix(1) ?? "U")
                            .foregroundColor(.gray)
                    )
                
                // Text field
                TextField("What's on your mind?", text: $commentText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                // Send button
                Button(action: {
                    if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.postComment(content: commentText)
                        commentText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(appBlueColor)
                        .font(.system(size: 20))
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: -1)
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchComments()
        }
    }
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image
                    }
                }
            }
        }
    }
}





// Constants and Extensions for Community Feature

import Foundation
import SwiftUI

// MARK: - Community API Constants
extension APIConstants {
    struct Community {
        static let posts = "/community/posts"
        static let userPosts = "/community/user/posts"
        static let post = "/community/posts/" // Append postId
        static let postComments = "/community/posts/" // Append postId + "/comments"
    }
}

// MARK: - Helper Extensions for Community Feature

// Helper function to log network requests in development
func logNetworkRequest(_ request: URLRequest) {
    #if DEBUG
    print("🌐 \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
    
    if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
        print("📝 Headers:")
        headers.forEach { key, value in
            if key != "Authorization" { // Don't print auth tokens
                print("  \(key): \(value)")
            } else {
                print("  \(key): [REDACTED]")
            }
        }
    }
    
    if let body = request.httpBody, !body.isEmpty,
       let bodyString = String(data: body, encoding: .utf8) {
        print("📦 Body: \(bodyString)")
    }
    #endif
}

// Helper function to log network responses in development
func logNetworkResponse(data: Data?, response: URLResponse?, error: Error?) {
    #if DEBUG
    if let error = error {
        print("❌ Error: \(error.localizedDescription)")
        return
    }
    
    guard let httpResponse = response as? HTTPURLResponse else {
        print("⚠️ Not an HTTP response")
        return
    }
    
    let statusCodeEmoji = (200...299).contains(httpResponse.statusCode) ? "✅" : "❌"
    print("\(statusCodeEmoji) Status Code: \(httpResponse.statusCode)")
    
    if let data = data, !data.isEmpty, let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
       let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        print("📦 Response: \(jsonString)")
    } else if let data = data, !data.isEmpty, let stringData = String(data: data, encoding: .utf8) {
        print("📦 Response: \(stringData)")
    }
    #endif
}

// Extension to handle timestamps and convert to readable format
extension String {
    func timeAgoDisplay() -> String {
        // For now, we'll just return the original string
        // In a real app, you'd parse the date and calculate relative time
        return self
    }
}

// Extension to handle avatar image URLs
extension String {
    var asAvatarURL: URL? {
        if self.isEmpty {
            return nil
        }
        
        if self.hasPrefix("http") {
            return URL(string: self)
        } else {
            // Handle relative URLs by appending to base URL
            return URL(string: APIConstants.baseURL + "/" + self.replacingOccurrences(of: "^/+", with: "", options: .regularExpression))
        }
    }
}


// Extensions to NetworkManager for Community API

import Foundation
import Combine

// MARK: - NetworkManager Extensions for Combine
extension NetworkManager {
    
    // Generic GET request with Combine
    func get<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil, requiresAuth: Bool = true) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if requiresAuth {
            authHeaders().forEach { request.addValue($0.value, forHTTPHeaderField: $0.name) }
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        // Add query parameters if provided
        if let parameters = parameters, !parameters.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = components.url
        }
        
        // Log request in debug mode
        logNetworkRequest(request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log response for debugging
                logNetworkResponse(data: data, response: response, error: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    return data
                } else if httpResponse.statusCode == 401 {
                    throw APIError.authenticationError("Authentication failed")
                } else {
                    // Try to parse server error message
                    if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                        throw APIError.serverError(serverError.message)
                    } else {
                        throw APIError.serverError("Server error with status code: \(httpResponse.statusCode)")
                    }
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                if let apiError = error as? APIError {
                    return apiError
                } else if let _ = error as? DecodingError {
                    return APIError.invalidData
                } else {
                    return APIError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Generic POST request with Combine
    func post<T: Decodable>(endpoint: String, parameters: [String: Any], requiresAuth: Bool = true) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if requiresAuth {
            authHeaders().forEach { request.addValue($0.value, forHTTPHeaderField: $0.name) }
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        // Encode parameters as JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            return Fail(error: APIError.unknown("Failed to encode parameters")).eraseToAnyPublisher()
        }
        
        // Log request in debug mode
        logNetworkRequest(request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log response for debugging
                logNetworkResponse(data: data, response: response, error: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    return data
                } else if httpResponse.statusCode == 401 {
                    throw APIError.authenticationError("Authentication failed")
                } else {
                    // Try to parse server error message
                    if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                        throw APIError.serverError(serverError.message)
                    } else {
                        throw APIError.serverError("Server error with status code: \(httpResponse.statusCode)")
                    }
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                if let apiError = error as? APIError {
                    return apiError
                } else if let _ = error as? DecodingError {
                    return APIError.invalidData
                } else {
                    return APIError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Generic DELETE request with Combine
    func delete<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil, requiresAuth: Bool = true) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if requiresAuth {
            authHeaders().forEach { request.addValue($0.value, forHTTPHeaderField: $0.name) }
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        // Encode parameters as JSON if provided
        if let parameters = parameters, !parameters.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                return Fail(error: APIError.unknown("Failed to encode parameters")).eraseToAnyPublisher()
            }
        }
        
        // Log request in debug mode
        logNetworkRequest(request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log response for debugging
                logNetworkResponse(data: data, response: response, error: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Some DELETE requests might return empty responses
                    if data.isEmpty && T.self == EmptyResponse.self {
                        // Create an empty JSON object "{}" for EmptyResponse
                        return "{}".data(using: .utf8)!
                    }
                    return data
                } else if httpResponse.statusCode == 401 {
                    throw APIError.authenticationError("Authentication failed")
                } else {
                    // Try to parse server error message
                    if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                        throw APIError.serverError(serverError.message)
                    } else {
                        throw APIError.serverError("Server error with status code: \(httpResponse.statusCode)")
                    }
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                if let apiError = error as? APIError {
                    return apiError
                } else if let _ = error as? DecodingError {
                    return APIError.invalidData
                } else {
                    return APIError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}




// Image Picker Implementation for Community Posts

import SwiftUI
import UIKit
import PhotosUI

// MARK: - Image Compression Helper
extension UIImage {
    func compressForUpload() -> Data? {
        // Start with 80% quality
        var compression: CGFloat = 0.8
        var imageData = self.jpegData(compressionQuality: compression)
        
        // Target file size in bytes (2MB)
        let maxFileSize: Int = 2 * 1024 * 1024
        
        // Compress until file size is under the limit or compression is too low
        while let data = imageData, data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}



