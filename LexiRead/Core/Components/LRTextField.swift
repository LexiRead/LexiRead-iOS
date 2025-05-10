//
//  LRTextField.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import SwiftUI

struct LRTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var trailingIcon: Image? = nil
    var trailingAction: (() -> Void)? = nil
    
    @State private var isTextVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Field title
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(.primary900))
            
            // Custom text field with optional secure entry
            HStack {
                if isSecure && !isTextVisible {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                        .keyboardType(keyboardType)
                }
                
                // Show trailing icon (like password visibility toggle)
                if let icon = trailingIcon {
                    Button(action: {
                        if isSecure {
                            isTextVisible.toggle()
                        }
                        trailingAction?()
                    }) {
                        icon
                            .foregroundColor(Color.gray)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .frame(width: 20, height: 20)
                    .background(
                        configuration.isOn
                            ? RoundedRectangle(cornerRadius: 4).fill(Color.blue.opacity(0.1))
                            : RoundedRectangle(cornerRadius: 4).fill(Color.white)
                    )
                
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color.blue)
                }
            }
            configuration.label
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
