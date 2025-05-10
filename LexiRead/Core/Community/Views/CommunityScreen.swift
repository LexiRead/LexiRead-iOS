

import SwiftUI
import Alamofire

//MARK: - CommunityScreen
struct CommunityScreen: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = CommunityViewModel()
    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
    
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
                            // Create and add the new post
                            createNewPost()
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
                            Text("G")
                                .foregroundColor(.gray)
                        )
                    
                    Text("Guy Hawkins")
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
            // Load sample data for my posts
            viewModel.myPosts = [
                Post(id: "1", userFullName: "Guy Hawkins", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil),
                Post(id: "2", userFullName: "Guy Hawkins", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil)
            ]
        }
    }
    
    // Function to create a new post
    private func createNewPost() {
        let newPost = Post(
            id: UUID().uuidString,
            userFullName: "Guy Hawkins",
            content: newPostText,
            timeAgo: "Just now",
            commentCount: 0,
            userProfileImage: nil
        )
        
        // Add to the beginning of the posts array
        viewModel.myPosts.insert(newPost, at: 0)
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

class CommunityViewModel: ObservableObject {
    @Published var forYouPosts: [Post] = []
    @Published var myPosts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let forYouEndpoint = "YOUR_API_URL/for_you"
    private let myPostsEndpoint = "YOUR_API_URL/my_posts"
    
    func fetchForYouPosts() {
        self.loadSampleData()
        
    }
    
    func fetchMyPosts() {
      
    }
    
    // Sample data for development and preview
    private func loadSampleData() {
        forYouPosts = [
            Post(id: "1", userFullName: "Wade Warren", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil),
            Post(id: "2", userFullName: "Bessie Cooper", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil),
            Post(id: "3", userFullName: "Bessie Cooper", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw semak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg jerawatan. di emak gw mah fine2 aja ga ngpa2 gw s", timeAgo: "45 minutes ago", commentCount: 45, userProfileImage: nil)
        ]
    }
    
    
    func deletePost(postId: String) {
        // In a real app, this would call an API
        // For now, we'll just remove it from the local array
        myPosts.removeAll { $0.id == postId }
    }
    
    
    func addPost(content: String) {
        // In a real app, you would make an API call
        let newPost = Post(
            id: UUID().uuidString,
            userFullName: "Guy Hawkins",
            content: content,
            timeAgo: "Just now",
            commentCount: 0,
            userProfileImage: nil
        )
        
        myPosts.insert(newPost, at: 0)
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
    private let commentsEndpoint: String
    private let postCommentEndpoint: String
    
    init(postId: String) {
        
        self.postId = postId
        self.commentsEndpoint = "YOUR_API_URL/posts/\(postId)/comments"
        self.postCommentEndpoint = "YOUR_API_URL/posts/\(postId)/comment"
        
        // For demo/preview purposes, load sample data
        self.loadSampleData()
    }
    
    func fetchComments() {
       
    }
    
    func postComment(content: String) {
        
        
        // For demo purposes, add a mock comment
        let newComment = Comment(
            id: UUID().uuidString,
            userFullName: "Current User",
            content: content,
            timeAgo: "Just now",
            userProfileImage: nil
        )
        
        self.comments.insert(newComment, at: 0)
    }
    
    // Sample data for development and preview
    private func loadSampleData() {
        comments = [
            Comment(id: "1", userFullName: "Jane Cooper", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg gw s", timeAgo: "45 minutes ago", userProfileImage: nil),
            Comment(id: "2", userFullName: "Cameron Williamson", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg gw s", timeAgo: "45 minutes ago", userProfileImage: nil),
            Comment(id: "3", userFullName: "Leslie Alexander", content: "emak gw yg make ni,w nyoba2 tp gabgt di komuk lgsg gw s", timeAgo: "45 minutes ago", userProfileImage: nil)
        ]
    }
}
