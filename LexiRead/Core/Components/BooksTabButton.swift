//
//  BooksTabButton.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/03/2025.
//

import SwiftUI

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(text)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)) : .gray)
                    .padding(.horizontal)
                
                Rectangle()
                    .frame(height: 3)
                    .foregroundColor(isSelected ? Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0)) : .clear)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
#Preview {
    TabButton(text: ".kjbhlgjkhb", isSelected: true) {
        
    }
}
