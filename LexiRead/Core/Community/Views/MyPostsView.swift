//
//  MyPostsView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 22/03/2025.
//

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


#Preview {
    MyPostsView()
}
