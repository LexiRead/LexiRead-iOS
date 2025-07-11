//
//  OTPTextField.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 11/07/2025.
//

import SwiftUI

// MARK: - OTP TextField
struct OTPTextField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 80, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary900, lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
            }
    }
}
