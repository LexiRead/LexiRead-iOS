////
////  FloatingActionButton.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 03/03/2025.
////
//
//import SwiftUI
//
//struct FloatingActionButton: View {
//    let action: () -> Void
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                Button(action: action) {
//                    ZStack {
//                        Circle()
//                            .foregroundColor(.main)
//                            .frame(width: 60, height: 60)
//                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
//                        
//                        Image(systemName: "arrow.up.doc")
//                            .font(.system(size: 24))
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.trailing, 20)
//                .padding(.bottom, 20)
//            }
//        }
//    }
//}
//#Preview {
//    FloatingActionButton {
//        
//    }
//}
