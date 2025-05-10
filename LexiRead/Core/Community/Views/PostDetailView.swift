//
//  PostDetailView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 22/03/2025.
//

//import SwiftUI
//
//struct PostDetailView: View {
//    let post: Post
//    @StateObject private var viewModel: PostDetailViewModel
//    @State private var commentText: String = ""
//    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
//    
//    init(post: Post) {
//        self.post = post
//        _viewModel = StateObject(wrappedValue: PostDetailViewModel(postId: post.id))
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Post content
//            ScrollView {
//                VStack(alignment: .leading, spacing: 0) {
//                    // Post header with user info
//                    HStack {
//                        // Profile image
//                        if let imageUrl = post.userProfileImage, !imageUrl.isEmpty {
//                            AsyncImage(url: URL(string: imageUrl)) { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                            } placeholder: {
//                                Circle()
//                                    .fill(Color.gray.opacity(0.3))
//                            }
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
//                        } else {
//                            Circle()
//                                .fill(Color.gray.opacity(0.3))
//                                .frame(width: 50, height: 50)
//                                .overlay(
//                                    Text(String(post.userFullName.prefix(1)))
//                                        .foregroundColor(.gray)
//                                )
//                        }
//                        
//                        VStack(alignment: .leading) {
//                            Text(post.userFullName)
//                                .font(.headline)
//                            
//                            HStack {
//                                Text("Shared a")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                                
//                                Text("Post")
//                                    .font(.subheadline)
//                                    .foregroundColor(.black)
//                            }
//                            
//                            Text(post.timeAgo)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        
//                        Spacer()
//                        
//                        // Three dots menu
//                        Menu {
//                            Button("Report", action: {})
//                            Button("Share", action: {})
//                        } label: {
//                            Image(systemName: "ellipsis")
//                                .rotationEffect(.degrees(90))
//                                .font(.title3)
//                                .foregroundColor(appBlueColor)
//                        }
//                    }
//                    .padding()
//                    
//                    // Post content
//                    Text(post.content)
//                        .font(.body)
//                        .padding()
//                    
//                    Divider()
//                    
//                    // Comments section header
//                    Text("Comments")
//                        .font(.headline)
//                        .padding(.horizontal)
//                        .padding(.top, 8)
//                    
//                    if viewModel.isLoading {
//                        ProgressView()
//                            .padding()
//                    } else if let errorMessage = viewModel.errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .padding()
//                    } else if viewModel.comments.isEmpty {
//                        Text("No comments yet")
//                            .foregroundColor(.gray)
//                            .padding()
//                    } else {
//                        // Comments list
//                        ForEach(viewModel.comments) { comment in
//                            CommentCell(comment: comment)
//                                .padding(.top, 8)
//                        }
//                        .padding(.bottom, 16)
//                    }
//                }
//            }
//            
//            // Comment input area at the bottom
//            HStack(spacing: 10) {
//                // Current user profile image
//                Circle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 40, height: 40)
//                
//                // Text field
//                TextField("What's on your mind?", text: $commentText)
//                    .padding(10)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(20)
//                
//                // Send button
//                Button(action: {
//                    if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                        viewModel.postComment(content: commentText)
//                        commentText = ""
//                    }
//                }) {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(appBlueColor)
//                        .font(.system(size: 20))
//                }
//            }
//            .padding()
//            .background(Color.white)
//            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: -1)
//        }
//        .navigationTitle("Post")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            viewModel.fetchComments()
//        }
//    }
//}


