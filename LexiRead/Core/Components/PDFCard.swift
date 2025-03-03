//
//  PDFCard.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/03/2025.
//

import SwiftUI

struct PDFCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let isPDF: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                if isPDF {
                    Image(systemName: "doc.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 100)
                        .foregroundColor(.red)
                } else {
                    // This would be replaced with AsyncImage for real implementation
                    // using the actual URL from the model
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 120)
                        .cornerRadius(8)
                }
                
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 150, height: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

#Preview {
    PDFCard(title: "Hello", subtitle: "lkadf", imageName: "", isPDF: false) {
        
    }
}
