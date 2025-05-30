////
////  MyPostCell.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 22/03/2025.
////
//
//import SwiftUI
//
//struct MyPostCell: View {
//    let post: Post
//    let onDeleteTap: () -> Void
//    @State private var showComments = false
//    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // User info and post time
//            HStack {
//                // Profile image
//                if let imageUrl = post.userProfileImage, !imageUrl.isEmpty {
//                    AsyncImage(url: URL(string: imageUrl)) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Circle()
//                            .fill(Color.gray.opacity(0.3))
//                    }
//                    .frame(width: 50, height: 50)
//                    .clipShape(Circle())
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(width: 50, height: 50)
//                        .overlay(
//                            Text(String(post.userFullName.prefix(1)))
//                                .foregroundColor(.gray)
//                        )
//                }
//                
//                VStack(alignment: .leading) {
//                    Text(post.userFullName)
//                        .font(.headline)
//                    
//                    HStack {
//                        Text("Shared a")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        
//                        Text("Post")
//                            .font(.subheadline)
//                            .foregroundColor(.black)
//                    }
//                    
//                    Text(post.timeAgo)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//                
//                // Delete button directly in the UI, matching the screenshot
//                
//                // Menu dots for other options
//                Menu {
//                    Button(action: onDeleteTap) {
//                        HStack {
//                            Image(systemName: "trash")
//                                .foregroundColor(.red)
//                            Text("Delete")
//                                .foregroundColor(.red)
//                        }
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color.red, lineWidth: 1)
//                        )
//                    }
//                    
//                } label: {
//                    Image(systemName: "ellipsis")
//                        .rotationEffect(.degrees(90))
//                        .font(.title3)
//                        .foregroundColor(.black)
//                        .padding(.leading, 8)
//                }
//            }
//            .padding(.horizontal)
//            
//            // Post content
//            Text(post.content)
//                .font(.body)
//                .padding(.horizontal)
//            
//            Divider()
//            
//            // Comment count - tappable to open comments
//            NavigationLink(destination: PostDetailView(post: post), isActive: $showComments) {
//                EmptyView()
//            }
//            .opacity(0)
//            
//            Button(action: {
//                showComments = true
//            }) {
//                HStack {
//                    Image(systemName: "message")
//                        .foregroundColor(.gray)
//                    
//                    Text("\(post.commentCount) Replay")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 8)
//            }
//        }
//        .background(Color.white)
//        .cornerRadius(8)
//        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
//        .padding(.horizontal, 16)
//        .padding(.vertical, 8)
//    }
//}
//
//struct CommentCell: View {
//    let comment: Comment
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 10) {
//            // Profile image
//            if let imageUrl = comment.userProfileImage, !imageUrl.isEmpty {
//                AsyncImage(url: URL(string: imageUrl)) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } placeholder: {
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                }
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//            } else {
//                Circle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 40, height: 40)
//                    .overlay(
//                        Text(String(comment.userFullName.prefix(1)))
//                            .foregroundColor(.gray)
//                    )
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                HStack {
//                    // User name
//                    Text(comment.userFullName)
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                    
//                    Spacer()
//                    
//                    // Time
//                    Text(comment.timeAgo)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    
//                    // Options menu
//                    Menu {
//                        Button("Report", action: {})
//                        Button("Copy", action: {})
//                    } label: {
//                        Image(systemName: "ellipsis")
//                            .rotationEffect(.degrees(90))
//                            .foregroundColor(.gray)
//                    }
//                }
//                
//                // Comment content
//                Text(comment.content)
//                    .font(.subheadline)
//                    .padding(.top, 2)
//            }
//        }
//        .padding(.horizontal)
//    }
//}
//
//struct PostCell: View {
//    let post: Post
//    @State private var showComments = false
//    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // User info and post time
//            HStack {
//                // Profile image
//                if let imageUrl = post.userProfileImage, !imageUrl.isEmpty {
//                    AsyncImage(url: URL(string: imageUrl)) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Circle()
//                            .fill(Color.gray.opacity(0.3))
//                    }
//                    .frame(width: 50, height: 50)
//                    .clipShape(Circle())
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(width: 50, height: 50)
//                        .overlay(
//                            Text(String(post.userFullName.prefix(1)))
//                                .foregroundColor(.gray)
//                        )
//                }
//                
//                VStack(alignment: .leading) {
//                    Text(post.userFullName)
//                        .font(.headline)
//                    
//                    HStack {
//                        Text("Shared a")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        
//                        Text("Post")
//                            .font(.subheadline)
//                            .foregroundColor(.black)
//                    }
//                    
//                    Text(post.timeAgo)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//                
//                // Three dots menu
//                Menu {
//                    Button("Report", action: {})
//                    Button("Share", action: {})
//                } label: {
//                    Image(systemName: "ellipsis")
//                        .rotationEffect(.degrees(90))
//                        .font(.title3)
//                        .foregroundColor(appBlueColor)
//                }
//            }
//            .padding(.horizontal)
//            
//            // Post content
//            Text(post.content)
//                .font(.body)
//                .padding(.horizontal)
//            
//            Divider()
//            
//            // Comment count - tappable to open comments
//            NavigationLink(destination: PostDetailView(post: post), isActive: $showComments) {
//                EmptyView()
//            }
//            .opacity(0)
//            
//            Button(action: {
//                showComments = true
//            }) {
//                HStack {
//                    Image(systemName: "message")
//                        .foregroundColor(.gray)
//                    
//                    Text("\(post.commentCount) Comment")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 8)
//            }
//        }
//        .background(Color.white)
//        .cornerRadius(8)
//        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
//        .padding(.horizontal, 16)
//        .padding(.vertical, 8)
//    }
//}
