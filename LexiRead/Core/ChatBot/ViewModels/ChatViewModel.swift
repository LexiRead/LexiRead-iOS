////
////  ChatViewModel.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 02/03/2025.
////
//
//import Foundation
//
//struct Message: Identifiable, Equatable {
//    let id = UUID()
//    let content: String
//    let isFromUser: Bool
//    let timestamp: Date = Date()
//}
//// Expected response structure - adjust based on your API
//struct BotResponse: Decodable {
//    let reply: String
//}
//
//class ChatViewModel: ObservableObject {
//    @Published var messages: [Message] = []
//    @Published var inputText: String = ""
//    @Published var isLoading: Bool = false
//    @Published var showDeleteAlert = false
//    @Published var showClearChatPopover = false
//
//    private let apiURL = "YOUR_API_ENDPOINT_HERE"
//    
//    func sendMessage() {
//        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        
//        // Add user message to the chat
//        let userMessage = Message(content: inputText, isFromUser: true)
//        messages.append(userMessage)
//        
//        // Store the input and clear it
//        let messageToSend = inputText
//        inputText = ""
//        
//        // Show loading state
//        isLoading = true
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
//            guard let self = self else { return }
//            self.isLoading = false
//        }
//        // Make API call
//        let parameters: [String: Any] = ["message": messageToSend]
//        
//        //        AF.request(apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
//        //            .validate()
//        //            .responseDecodable(of: BotResponse.self) { [weak self] response in
//        //                self?.isLoading = false
//        //                
//        //                switch response.result {
//        //                case .success(let botResponse):
//        //                    // Add bot response to the chat
//        //                    let botMessage = Message(content: botResponse.reply, isFromUser: false)
//        //                    self?.messages.append(botMessage)
//        //                case .failure(let error):
//        //                    // Handle error
//        //                    print("Error: \(error.localizedDescription)")
//        //                    let errorMessage = Message(content: "Sorry, I couldn't process your request.", isFromUser: false)
//        //                    self?.messages.append(errorMessage)
//        //                }
//        //            }
//    }
//}
//
