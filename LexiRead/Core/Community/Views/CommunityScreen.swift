

import SwiftUI
import Alamofire

//MARK: - CommunityScreen
struct CommunityScreen: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = CommunityViewModel()
    private let appBlueColor = Color(.primary900)
    
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

#Preview {
    CommunityScreen()
}


//MARK: - MyPostsView
import SwiftUI

struct MyPostsView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showingDeleteAlert = false
    @State private var postToDelete: Post?
    @State private var newPostText: String = ""
    @State private var showingPostSheet = false
    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
    
    var body: some View {
        VStack(spacing: 0) {
            // "What's on your mind?" text field
            HStack(spacing: 12) {
                // User profile image
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("G")
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
        .sheet(isPresented: $showingPostSheet) {
            // Post creation sheet
            VStack(spacing: 0) {
                // Header with cancel and post buttons
                HStack {
                    Button("Cancel") {
                        showingPostSheet = false
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
                            viewModel.addPost(content: newPostText)
                            newPostText = ""
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
                            Text("a")
                                .foregroundColor(.gray)
                        )
                    
                    Text("ahmeddd")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding()
                
                // Text editor for post content
                TextEditor(text: $newPostText)
                    .padding()
                    .background(Color.white)
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchMyPosts()
        }
    }
}






//MARK: - PostDetailView
import SwiftUI

struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel: PostDetailViewModel
    @State private var commentText: String = ""
    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
    
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




//MARK: - view models

//
//  CommunityViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 22/03/2025.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

class CommunityViewModel: ObservableObject {
    @Published var forYouPosts: [Post] = []
    @Published var myPosts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchForYouPosts() {
        isLoading = true
        errorMessage = nil
        
        NetworkingService.shared.fetchCommunityPosts { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let posts):
                self.forYouPosts = posts
                if posts.isEmpty {
                    self.errorMessage = "No posts available"
                }
            case .failure(let error):
                self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                print("Error fetching for you posts: \(error)")
            }
        }
    }
    
    func fetchMyPosts() {
        isLoading = true
        errorMessage = nil
        
        NetworkingService.shared.fetchMyPosts { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let posts):
                self.myPosts = posts
                if posts.isEmpty {
                    self.errorMessage = "No posts available"
                }
            case .failure(let error):
                self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                print("Error fetching my posts: \(error)")
            }
        }
    }
    
    func deletePost(postId: String) {
        isLoading = true
        errorMessage = nil
        
        NetworkingService.shared.deletePost(postId: postId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(_):
                // Remove post from local array
                self.myPosts.removeAll { $0.id == postId }
            case .failure(let error):
                self.errorMessage = "Failed to delete post: \(error.localizedDescription)"
                print("Error deleting post: \(error)")
            }
        }
    }
    
    func addPost(content: String) {
        isLoading = true
        errorMessage = nil
        
        NetworkingService.shared.createPost(content: content) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let post):
                // Add new post to the top of the list
                self.myPosts.insert(post, at: 0)
            case .failure(let error):
                self.errorMessage = "Failed to create post: \(error.localizedDescription)"
                print("Error creating post: \(error)")
            }
        }
    }
}

//MARK: - PostDetailViewModel

//
//  PostDetailViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 22/03/2025.
//

import Foundation

class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let postId: String
    
    init(postId: String) {
        self.postId = postId
    }
    
    func fetchComments() {
        isLoading = true
        errorMessage = nil
        
        NetworkingService.shared.fetchPostComments(postId: postId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let comments):
                self.comments = comments
                if comments.isEmpty {
                    self.errorMessage = "No comments yet"
                }
            case .failure(let error):
                self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                print("Error fetching comments: \(error)")
            }
        }
    }
    
    func postComment(content: String) {
        isLoading = true
        errorMessage = nil
        
        NetworkingService.shared.postComment(postId: postId, content: content) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let comment):
                // Add new comment to the top of the list
                self.comments.insert(comment, at: 0)
            case .failure(let error):
                self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
                print("Error posting comment: \(error)")
            }
        }
    }
}




//MARK: - api service

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case noData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Network request failed"
        case .decodingFailed:
            return "Failed to decode response"
        case .noData:
            return "No data received"
        }
    }
}

class NetworkingService {
    static let shared = NetworkingService()
    
    private let baseURL = "http://40.76.247.35/api"
    private let token = "5|I3mh0xpU8GilTs5AlAq268eH5AuE323iDd6XWMHU463338e6"
    
    private init() {}
    
    // MARK: - Create URL Request
    private func createRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Log the request in debug mode
        logNetworkRequest(request)
        
        return request
    }
    
    // MARK: - Fetch Community Posts (For You)
    func fetchCommunityPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/community/posts") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = createRequest(url: url, method: "GET")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log response for debugging
            logNetworkResponse(data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let postsResponse = try JSONDecoder().decode(PaginatedPostsResponse.self, from: data)
                
                let posts = postsResponse.data.data.map { postData in
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
                
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                print("Error decoding community posts: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch My Posts
    func fetchMyPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/community/user/posts") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = createRequest(url: url, method: "GET")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log response for debugging
            logNetworkResponse(data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let postsResponse = try JSONDecoder().decode(PaginatedPostsResponse.self, from: data)
                
                let posts = postsResponse.data.data.map { postData in
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
                
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                print("Error decoding my posts: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed))
                }
            }
        }.resume()
    }
    
    // MARK: - Create Post
    func createPost(content: String, completion: @escaping (Result<Post, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/community/posts") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = createRequest(url: url, method: "POST")
        
        let parameters = ["content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log response for debugging
            logNetworkResponse(data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let createPostResponse = try JSONDecoder().decode(CreatePostResponse.self, from: data)
                let postData = createPostResponse.data.post
                
                let post = Post(
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
                
                DispatchQueue.main.async {
                    completion(.success(post))
                }
            } catch {
                print("Error decoding create post response: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed))
                }
            }
        }.resume()
    }
    
    // MARK: - Delete Post
    func deletePost(postId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/community/posts/\(postId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = createRequest(url: url, method: "DELETE")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log response for debugging
            logNetworkResponse(data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Check if we got a success status code
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Post Comments
    func fetchPostComments(postId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/community/posts/\(postId)/comments") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = createRequest(url: url, method: "GET")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log response for debugging
            logNetworkResponse(data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let commentsResponse = try JSONDecoder().decode(PaginatedCommentsResponse.self, from: data)
                
                let comments = commentsResponse.data.data.map { commentData in
                    Comment(
                        id: String(commentData.id),
                        userFullName: commentData.user.name,
                        content: commentData.content,
                        timeAgo: commentData.created_at,
                        userProfileImage: commentData.user.avatar.isEmpty ? nil : commentData.user.avatar
                    )
                }
                
                DispatchQueue.main.async {
                    completion(.success(comments))
                }
            } catch {
                print("Error decoding comments: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed))
                }
            }
        }.resume()
    }
    
    // MARK: - Post Comment
    func postComment(postId: String, content: String, completion: @escaping (Result<Comment, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/community/posts/\(postId)/comments") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = createRequest(url: url, method: "POST")
        
        let parameters = ["content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log response for debugging
            logNetworkResponse(data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                // Try to decode as a CreateCommentResponse
                let commentResponse = try JSONDecoder().decode(CreateCommentResponse.self, from: data)
                let commentData = commentResponse.data.comment
                
                let comment = Comment(
                    id: String(commentData.id),
                    userFullName: commentData.user.name,
                    content: commentData.content,
                    timeAgo: commentData.created_at,
                    userProfileImage: commentData.user.avatar.isEmpty ? nil : commentData.user.avatar
                )
                
                DispatchQueue.main.async {
                    completion(.success(comment))
                }
            } catch {
                print("Error decoding create comment response: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed))
                }
            }
        }.resume()
    }
}




//MARK: - RESPONSE MODELS
// Response models for parsing API responses

import Foundation

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


//MARK: - Models
import Foundation

// Models used in the UI
struct Post: Identifiable {
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

struct Comment: Identifiable {
    let id: String
    let userFullName: String
    let content: String
    let timeAgo: String
    let userProfileImage: String?
}




import Foundation

// Utility extension to help print network responses when debugging
extension Data {
    func prettyPrintedJSONString() -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

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
       let bodyString = body.prettyPrintedJSONString() {
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
    
    if let data = data, !data.isEmpty, let jsonString = data.prettyPrintedJSONString() {
        print("📦 Response: \(jsonString)")
    } else if let data = data, !data.isEmpty, let stringData = String(data: data, encoding: .utf8) {
        print("📦 Response: \(stringData)")
    }
    #endif
}
