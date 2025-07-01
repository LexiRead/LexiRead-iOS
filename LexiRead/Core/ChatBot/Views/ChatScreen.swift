//
//  ChatScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 02/03/2025.
//

// ChatScreen.swift
import SwiftUI
import Combine




// MARK: - Models

// Chat Models
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: Int
    let chat_id: Int
    let sender: String
    let message: String
    let created_at: String
    let is_user: Bool
    
    // Convert API model to UI model
    func toUIMessage() -> Message {
        return Message(id: "\(id)", content: message, isFromUser: is_user)
    }
}

struct ChatPreview: Codable {
    let sender: String
    let message: String
    let created_at: String
}

struct Chat: Codable {
    let id: Int
    let title: String
    let created_at: String
    let last_message_at: String
    let message_count: Int
    let messages: [ChatMessage]
    let preview: ChatPreview
}

struct ChatResponse: Codable {
    let chat: Chat
    let user_message: ChatMessage
    let ai_response: ChatMessage
}

struct ChatAPIResponse: Codable {
    let data: ChatResponse
}

// Update Message model to match the project structure
struct Message: Identifiable, Equatable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(id: String = UUID().uuidString, content: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

// MARK: - API Constants Extension
extension APIConstants.Endpoints {
    static let geminiChat = "gemini/chat"
}



// Update ChatScreen to accept an optional initial message
struct ChatScreen: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Initialize with optional initial text
    init(initialText: String? = nil) {
        // Use StateObject with a custom initializer that takes the initial text
        _viewModel = StateObject(wrappedValue: ChatViewModel(initialText: initialText))
    }
    
    var body: some View {
        VStack {
            // Header
            HeaderView(viewModel: viewModel)
                .alert(isPresented: $viewModel.showDeleteAlert) {
                    Alert(
                        title: Text("Delete Conversation"),
                        message: Text("Are you sure you want to delete the entire conversation? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.clearChat() // Use the animated clear method
                        },
                        secondaryButton: .cancel()
                    )
                }
            
            // Clear Chat Popover
            if viewModel.showClearChatPopover {
                ClearChatPopover(viewModel: viewModel)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
            
            // Chat Messages
            ChatMessagesView(viewModel: viewModel)
                .animation(.easeInOut, value: viewModel.messages)
            
            // Input Field
            InputFieldView(viewModel: viewModel)
        }
        .toolbar(.hidden)
    }
}


struct HeaderView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        HStack {
            BackButton()
            Spacer()
            Text("Lixebot")
                .font(.title)
                .foregroundColor(.darkerBlue)
                .bold()
            Spacer()
            // Menu button (three dots)
            Button(action: {
                viewModel.showClearChatPopover.toggle()
            }) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.darkerBlue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
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


// Updated ChatMessagesView with smooth scrolling animation
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
                    // Use a slight delay to ensure the view has been updated
                    // with the new message before attempting to scroll
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}


struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer(minLength: 200)
            
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
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).animation(.easeInOut(duration: 0.3)),
                        removal: .opacity.animation(.easeInOut(duration: 0.2))
                    ))
            }
            
            if viewModel.isLoading {
                HStack {
                    Text("Typing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
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
                        .foregroundColor(.darkerBlue)
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


//
//  ChatViewModel.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 02/03/2025.
//

import Foundation


// Expected response structure - adjust based on your API
struct BotResponse: Decodable {
    let reply: String
}

// MARK: - Updated ChatViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var showDeleteAlert = false
    @Published var showClearChatPopover = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Initialize with optional initial text
    init(initialText: String? = nil) {
        if let text = initialText {
            self.inputText = text
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Store the input and clear it
        let messageToSend = inputText
        inputText = ""
        
        // Add user message to the chat with animation
        let userMessage = Message(content: messageToSend, isFromUser: true)
        withAnimation(.easeIn(duration: 0.3)) {
            messages.append(userMessage)
        }
        
        // Show loading state
        isLoading = true
        
        // Make the API call
        ChatService.shared.sendMessage(messageToSend)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                withAnimation(.easeOut(duration: 0.2)) {
                    self.isLoading = false
                }
                
                if case .failure(let error) = completion {
                    // Handle error
                    let errorMessage = Message(
                        content: "Sorry, there was a problem: \(error.localizedDescription)",
                        isFromUser: false
                    )
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.messages.append(errorMessage)
                    }
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // Add bot response to messages with animation
                let botMessage = Message(
                    id: "\(response.ai_response.id)",
                    content: response.ai_response.message,
                    isFromUser: false
                )
                
                // Small delay to make typing indicator visible and feel more natural
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.messages.append(botMessage)
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // Clear chat history with animation
    func clearChat() {
        withAnimation(.easeOut(duration: 0.5)) {
            messages = []
        }
    }
}


//
//  ChatBubble.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 02/03/2025.
//

import SwiftUI

// MARK: - Views
struct ChatBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                FormattedText(content: message.content, isFromUser: true)
                    .padding(12)
                    .background(.darkerBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            } else {
                FormattedText(content: message.content, isFromUser: false)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatBubble(message: Message(content: "hi", isFromUser: true))
    ChatBubble(message: Message(content: "hi", isFromUser: false))
}


extension NetworkService {
    func sendChatMessage(_ message: String, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        let parameters: [String: Any] = ["message": message]
        
        NetworkManager.shared.post(endpoint: APIConstants.Endpoints.geminiChat,
                                   parameters: parameters,
                                   requiresAuth: true) { (result: Result<ChatAPIResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


// MARK: - Chat Service
class ChatService {
    static let shared = ChatService()
    
    private init() {}
    
    // Send a message to the chat bot
    func sendMessage(_ message: String) -> AnyPublisher<ChatResponse, APIError> {
        return Future<ChatResponse, APIError> { promise in
            NetworkService.shared.sendChatMessage(message) { result in
                switch result {
                case .success(let data):
                    promise(.success(data))
                case .failure(let error):
                    promise(.failure(APIError.mapError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


// MARK: - Simple Text Formatting Helper
struct FormattedText: View {
    let content: String
    let isFromUser: Bool
    
    var body: some View {
        Text("\(parseFormattedText())")
            .foregroundColor(isFromUser ? .white : .primary)
    }
    
    private func parseFormattedText() -> Text {
        let segments = parseMarkdownSegments(content)
        var result = Text("")
        
        for segment in segments {
            let textSegment = Text(segment.text)
            
            let formattedSegment: Text
            switch segment.style {
            case .bold:
                formattedSegment = textSegment.bold()
            case .italic:
                formattedSegment = textSegment.italic()
            case .code:
                formattedSegment = textSegment
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 4)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(4) as! Text
            case .strikethrough:
                formattedSegment = textSegment.strikethrough()
            case .normal:
                formattedSegment = textSegment
            }
            
            result = result + formattedSegment
        }
        
        return result
    }
}

// MARK: - Text Segment Model
struct TextSegment {
    let text: String
    let style: TextStyle
}

enum TextStyle {
    case normal
    case bold
    case italic
    case code
    case strikethrough
}

// MARK: - Markdown Parser
func parseMarkdownSegments(_ text: String) -> [TextSegment] {
    var segments: [TextSegment] = []
    var currentIndex = text.startIndex
    
    while currentIndex < text.endIndex {
        let remainingText = String(text[currentIndex...])
        
        // Check for bold (**text** or __text__)
        if let boldMatch = findMarkdownMatch(in: remainingText, patterns: ["\\*\\*(.*?)\\*\\*", "__(.*?)__"]) {
            // Add any text before the match
            if boldMatch.preText.count > 0 {
                segments.append(TextSegment(text: boldMatch.preText, style: .normal))
            }
            // Add the bold text
            segments.append(TextSegment(text: boldMatch.content, style: .bold))
            currentIndex = text.index(currentIndex, offsetBy: boldMatch.fullMatchLength)
        }
        // Check for italic (*text* or _text_)
        else if let italicMatch = findMarkdownMatch(in: remainingText, patterns: ["(?<!\\*)\\*([^*\\n]+)\\*(?!\\*)", "(?<!_)_([^_\\n]+)_(?!_)"]) {
            if italicMatch.preText.count > 0 {
                segments.append(TextSegment(text: italicMatch.preText, style: .normal))
            }
            segments.append(TextSegment(text: italicMatch.content, style: .italic))
            currentIndex = text.index(currentIndex, offsetBy: italicMatch.fullMatchLength)
        }
        // Check for code (`text`)
        else if let codeMatch = findMarkdownMatch(in: remainingText, patterns: ["`([^`\\n]+)`"]) {
            if codeMatch.preText.count > 0 {
                segments.append(TextSegment(text: codeMatch.preText, style: .normal))
            }
            segments.append(TextSegment(text: codeMatch.content, style: .code))
            currentIndex = text.index(currentIndex, offsetBy: codeMatch.fullMatchLength)
        }
        // Check for strikethrough (~~text~~)
        else if let strikeMatch = findMarkdownMatch(in: remainingText, patterns: ["~~([^~\\n]+)~~"]) {
            if strikeMatch.preText.count > 0 {
                segments.append(TextSegment(text: strikeMatch.preText, style: .normal))
            }
            segments.append(TextSegment(text: strikeMatch.content, style: .strikethrough))
            currentIndex = text.index(currentIndex, offsetBy: strikeMatch.fullMatchLength)
        }
        // No more matches, add the rest as normal text
        else {
            segments.append(TextSegment(text: remainingText, style: .normal))
            break
        }
    }
    
    return segments
}

struct MarkdownMatch {
    let preText: String
    let content: String
    let fullMatchLength: Int
}

func findMarkdownMatch(in text: String, patterns: [String]) -> MarkdownMatch? {
    for pattern in patterns {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: text.count)
            
            if let match = regex.firstMatch(in: text, options: [], range: range) {
                let preText = String(text.prefix(match.range.location))
                let capturedContent = (text as NSString).substring(with: match.range(at: 1))
                
                return MarkdownMatch(
                    preText: preText,
                    content: capturedContent,
                    fullMatchLength: preText.count + match.range.length
                )
            }
        } catch {
            print("Regex error for pattern \(pattern): \(error)")
        }
    }
    
    return nil
}
