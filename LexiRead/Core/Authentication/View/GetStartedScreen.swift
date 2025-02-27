//
//  GetStartedScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//

import SwiftUI

struct GetStartedScreen: View {
    
    var body: some View {
        NavigationStack{
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
                NavigationLink {
                    LoginScreen()
                } label: {
                    TextButton(title: "Log in")
                }

                
                NavigationLink {
                    SignUPScreen()
                } label: {
                    Text("Sign up")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBlue))
                        .frame(maxWidth:.infinity, minHeight: 56)
                }
            }
            .padding()
            .toolbarVisibility(.hidden)
        }
    }
}

#Preview {
    GetStartedScreen()
}
