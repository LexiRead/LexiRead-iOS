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
                Text(message.content)
                    .padding(12)
                    .background(Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            } else {
                Text(message.content)
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(.primary)
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
