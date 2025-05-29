////
////  PDFCard.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 03/03/2025.
////
//
//import SwiftUI
//
//// PDFCard.swift - Update this to handle URL images
//struct PDFCard: View {
//    let title: String
//    let subtitle: String
//    let imageURL: String
//    let isPDF: Bool
//    
//    @State private var image: UIImage? = nil
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            // Cover image
//            if isPDF {
//                Image(systemName: "doc.text.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: 150)
//                    .foregroundColor(.gray)
//                    .padding()
//            } else if let loadedImage = image {
//                Image(uiImage: loadedImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(height: 150)
//                    .cornerRadius(8)
//            } else {
//                Image(systemName: "book.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: 150)
//                    .foregroundColor(.gray)
//                    .padding()
//            }
//            
//            // Text content
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.headline)
//                    .lineLimit(2)
//                
//                if !subtitle.isEmpty {
//                    Text(subtitle)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .lineLimit(1)
//                }
//            }
//            .padding(.vertical, 4)
//        }
//        .onAppear {
//            // Load the image from URL if available
//            if !isPDF && !imageURL.isEmpty {
//                loadImageFromURL()
//            }
//        }
//    }
//    
//    // Load image from URL
//    private func loadImageFromURL() {
//        guard let url = URL(string: imageURL) else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data, let loadedImage = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.image = loadedImage
//                }
//            }
//        }.resume()
//    }
//}
