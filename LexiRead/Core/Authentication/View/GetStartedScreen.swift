//
//  GetStartedScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 26/02/2025.
//


import SwiftUI

struct GetStartedScreen: View {
    @StateObject private var viewModel = GetStartedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Logo and App Name
                VStack(spacing: 8) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 70)
                    
                    
                    Text("LexiRead")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.darkerBlue)
                }
                .padding(.top, 60)
                
                // Title
                VStack(spacing: 16) {
                    Text("Let's Get Started")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary900)
                    
                    Text("Log in or join us")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                // Social Login Buttons
                //                VStack(spacing: 16) {
                //                    Button {
                //                        viewModel.loginWithFacebook()
                //                    } label: {
                //                        HStack {
                //                            Image("FBImage")
                //                                .resizable()
                //                                .scaledToFit()
                //                                .frame(width: 24, height: 24)
                //                                .padding(.leading, 16)
                //
                //                            Text("Continue With Facebook")
                //                                .font(.headline)
                //                                .foregroundColor(.primary900)
                //
                //
                //                        }
                //                        .frame(maxWidth: .infinity, minHeight: 56)
                //                        .overlay(
                //                            RoundedRectangle(cornerRadius: 8)
                //                                .stroke(Color(.darkerBlue), lineWidth: 1)
                //                        )
                //                    }
                //
                //                    Button {
                //                        viewModel.loginWithGoogle()
                //                    } label: {
                //                        HStack {
                //                            Image("GImage")
                //                                .resizable()
                //                                .scaledToFit()
                //                                .frame(width: 24, height: 24)
                //                                .padding(.leading, 16)
                //
                //                            Text("Continue With Google")
                //                                .font(.headline)
                //                                .foregroundColor(.primary900)
                //
                //                        }
                //                        .frame(maxWidth: .infinity, minHeight: 56)
                //                        .overlay(
                //                            RoundedRectangle(cornerRadius: 8)
                //                                .stroke(Color(.darkerBlue), lineWidth: 1)
                //                        )
                //                    }
                //                }
                //
                //                // OR Divider
                //                LRDividerWithText(text: "OR")
                
                // Login Button
                VStack(spacing: 16){
                    NavigationLink {
                        LoginScreen()
                    } label: {
                        LRButton(title: "Log in", isPrimary: true)
                    }
                    
//                    LRDividerWithText(text: "OR")
                    // Sign Up Button
                    NavigationLink {
                        SignUpScreen()
                    } label: {
                        LRButton(title: "Sign up", isPrimary: false)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .toolbarVisibility(.hidden)
        }
    }
}
