//
//  LRDividerWithText.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import SwiftUI

// MARK: - LRDividerWithText
struct LRDividerWithText: View {
    let text: String
    
    var body: some View {
        HStack {
            VStack { Divider() }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            VStack { Divider() }
        }
    }
}

