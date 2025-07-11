//
//  LRButton.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import SwiftUI

// MARK: - LRButton
struct LRButton: View {
    var title: String
    var isPrimary: Bool = true
    var action: () -> Void = {}
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(isPrimary ? .white : Color(.darkerBlue))
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(isPrimary ? Color(.darkerBlue) : Color(.lrGray))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isPrimary ? Color.clear : Color(.darkerBlue), lineWidth: 1)
            )
    }
}
