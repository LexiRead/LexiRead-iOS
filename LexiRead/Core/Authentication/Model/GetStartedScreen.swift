//
//  GetStartedScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import SwiftUI

struct GetStartedScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo placeholder - replace this with your image
            VStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 70)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .padding()
                
                Text("LixeRead")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            .padding(.top, 60)
            
            VStack(spacing: 16) {
                Text("Let's Get Started")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.black)
                
                
                Text("Log in or join us")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .padding(.bottom, 20)
            }
            Spacer()
            
            // Login Button
            Button(action: {
                // Handle login action
            }) {
                Text("Log in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBlue))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            
            // Sign in Button (which may actually be a sign up button)
            Button(action: {
                // Handle sign in/up action
            }) {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            .padding(.bottom, 30)
        }
        .padding()
    }
}

#Preview {
    GetStartedScreen()
}
