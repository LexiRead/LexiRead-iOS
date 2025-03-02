//
//  ChatScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 02/03/2025.
//

//import SwiftUI
//
//struct ChatScreen: View {
//    @StateObject private var viewModel = ChatViewModel()
//    
//    var body: some View {
//        VStack {
//            // Navigation bar - just a title since you mentioned the back arrow is default
//            HStack {
//                Spacer()
//                Spacer()
//                Spacer()
//                Spacer()
//                Text("Lixebot")
//                    .font(.title)
//                    .foregroundColor(Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)))
//                    .bold()
//                Spacer()
//                Spacer()
//                Spacer()
//                // Menu button (three dots)
//                Button(action: {
//                    viewModel.showClearChatPopover.toggle()
//                }) {
//                    Image(systemName: "ellipsis")
//                        .font(.title2)
//                        .foregroundColor(Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)))
//                }
//                
//            }
//            .padding(.horizontal)
//            .alert(isPresented: $viewModel.showDeleteAlert) {
//                Alert(
//                    title: Text("Delete Conversation"),
//                    message: Text("Are you sure you want to delete the entire conversation? This action cannot be undone."),
//                    primaryButton: .destructive(Text("Delete")) {
//                        viewModel.messages = []
//                    },
//                    secondaryButton: .cancel()
//                )
//            }
//            
//            // Custom popover
//            if viewModel.showClearChatPopover {
//                ZStack {
//                    Spacer()
//                        .frame(height: 60)
//                    
//                    HStack {
//                        Spacer()
//                        
//                        // Custom popover content
//                        VStack {
//                            Button(action: {
//                                viewModel.showClearChatPopover = false
//                                viewModel.showDeleteAlert = true
//                            }) {
//                                HStack {
//                                    Image(systemName: "trash.fill")
//                                        .foregroundColor(Color(UIColor(red: 219/255, green: 88/255, blue: 73/255, alpha: 1.0)))
//                                    Text("Clear chat")
//                                        .foregroundColor(Color(UIColor(red: 219/255, green: 88/255, blue: 73/255, alpha: 1.0)))
//                                        .font(.system(size: 16))
//                                }
//                                .padding(.vertical, 12)
//                                .padding(.horizontal, 16)
//                                .frame(width: 180)
//                                .background(Color(UIColor.systemGray6))
//                                .cornerRadius(16)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                        .padding(.trailing, 16)
//                    }
//                    
//                    Spacer()
//                }
//                .background(
//                    Color.black.opacity(0.001) // Nearly transparent background
//                        .onTapGesture {
//                            viewModel.showClearChatPopover = false
//                        }
//                )
//            }
//            
//            // Chat messages
//            ScrollViewReader { proxy in
//                ScrollView {
//                    VStack(spacing: 0) {
//                        if viewModel.messages.isEmpty {
//                            
//                            Spacer()
//                            Image("chatBotImge")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120, height: 120)
//                            
//                            Text("How can i help you today?")
//                                .font(.title2)
//                                .foregroundColor(.secondary)
//                                .padding(.top)
//                            
//                        } else {
//                            ForEach(viewModel.messages) { message in
//                                ChatBubble(message: message)
//                                    .id(message.id)
//                            }
//                            
//                            if viewModel.isLoading {
//                                HStack {
//                                    Text("Typing...")
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                        .padding(.horizontal, 16)
//                                        .padding(.vertical, 8)
//                                    Spacer()
//                                }
//                            }
//                        }
//                    }
//                    .padding(.vertical)
//                }
//                .onChange(of: viewModel.messages) { messages in
//                    if let lastMessage = messages.last {
//                        withAnimation {
//                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
//                        }
//                    }
//                }
//            }
//            
//            // Input field and send button
//            HStack {
//                ZStack(alignment: .trailing) {
//                    TextField("Text Here", text: $viewModel.inputText)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                        .padding(.trailing, 40)
//                        .background(Color(UIColor.systemGray6))
//                        .cornerRadius(25)
//                    
//                    Button(action: {
//                        viewModel.sendMessage()
//                    }) {
//                        Image("sendImage")
//                            .font(.system(size: 20))
//                            .frame(width: 40, height: 40)
//                    }
//                    .padding(.trailing, 8)
//                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//        }
//    }
//}

// ChatScreen.swift
import SwiftUI

struct ChatScreen: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            // Header
            HeaderView(viewModel: viewModel)
                .alert(isPresented: $viewModel.showDeleteAlert) {
                    Alert(
                        title: Text("Delete Conversation"),
                        message: Text("Are you sure you want to delete the entire conversation? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.messages = []
                        },
                        secondaryButton: .cancel()
                    )
                }
            
            // Clear Chat Popover
            if viewModel.showClearChatPopover {
                ClearChatPopover(viewModel: viewModel)
            }
            
            // Chat Messages
            ChatMessagesView(viewModel: viewModel)
            
            // Input Field
            InputFieldView(viewModel: viewModel)
        }
    }
}


struct HeaderView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Text("Lixebot")
                .font(.title)
                .foregroundColor(Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)))
                .bold()
            Spacer()
            Spacer()
            Spacer()
            // Menu button (three dots)
            Button(action: {
                viewModel.showClearChatPopover.toggle()
            }) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)))
            }
        }
        .padding(.horizontal)
    }
}

struct ClearChatPopover: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        ZStack {
            Spacer()
                .frame(height: 60)
            
            HStack {
                Spacer()
                
                // Custom popover content
                VStack {
                    Button(action: {
                        viewModel.showClearChatPopover = false
                        viewModel.showDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(Color(UIColor(red: 219/255, green: 88/255, blue: 73/255, alpha: 1.0)))
                            Text("Clear chat")
                                .foregroundColor(Color(UIColor(red: 219/255, green: 88/255, blue: 73/255, alpha: 1.0)))
                                .font(.system(size: 16))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(width: 180)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.trailing, 16)
            }
            
            Spacer()
        }
        .background(
            Color.black.opacity(0.001) // Nearly transparent background
                .onTapGesture {
                    viewModel.showClearChatPopover = false
                }
        )
    }
}

struct ChatMessagesView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.messages.isEmpty {
                        EmptyStateView()
                    } else {
                        MessagesListView(viewModel: viewModel)
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: viewModel.messages) { messages in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}


struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            VStack(spacing: 16) {
                Image("chatBotImge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("How can i help you today?")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 0)
        }
    }
}


struct MessagesListView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.messages) { message in
                ChatBubble(message: message)
                    .id(message.id)
            }
            
            if viewModel.isLoading {
                HStack {
                    Text("Typing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    Spacer()
                }
            }
        }
    }
}


struct InputFieldView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField("Text Here", text: $viewModel.inputText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.trailing, 40)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(25)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image("sendImage")
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                }
                .padding(.trailing, 8)
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ChatScreen()
}
