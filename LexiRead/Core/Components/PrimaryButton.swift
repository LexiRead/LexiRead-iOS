//
//  PrimaryButton.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
        let action: () -> Void
        var backgroundColor: Color = Color(UIColor.systemBlue)
        var foregroundColor: Color = .white
        var height: CGFloat = 56
        var fontSize: CGFloat = 16
        var fontWeight: Font.Weight = .semibold
        var isFullWidth: Bool = true
        var horizontalPadding: CGFloat = 20
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(foregroundColor)
                    .frame(maxWidth: isFullWidth ? .infinity : nil, minHeight: height)
                    .padding(.horizontal, 16)
                    .background(backgroundColor)
                    .cornerRadius(18)
            }
//            .padding(.horizontal, horizontalPadding)
        }
}

#Preview {
    PrimaryButton(title: "Log in") {
        
    }
}
