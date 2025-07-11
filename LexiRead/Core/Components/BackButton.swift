//
//  BackButton.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Optional custom action closure
    let customAction: (() -> Void)?
    
    // Initializer that accepts an optional action
    init(action: (() -> Void)? = nil) {
        self.customAction = action
    }
    
    var body: some View {
        Button(action: {
            // If custom action is provided, use it
            if let customAction = customAction {
                customAction()
            } else {
                // Default behavior: dismiss current screen
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary900)
                .imageScale(.large)
        }
    }
}
