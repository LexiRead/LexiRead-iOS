////
////  DummyUser.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 25/02/2025.
////
//
//import SwiftUI
//
//struct UserListView: View {
//    @StateObject private var viewModel = UserViewModel()
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                List {
//                    ForEach(viewModel.users, id: \.id) { user in
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text(user.name)
//                                .font(.headline)
//                            
//                            Text(user.email)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//                .listStyle(InsetGroupedListStyle())
//                .refreshable {
////                    viewModel.fetchUsers()
//                }
//                
//                if viewModel.isLoading {
//                    ProgressView()
//                        .scaleEffect(1.5)
//                }
//                
//                if let errorMessage = viewModel.errorMessage {
//                    VStack {
//                        Text("Error")
//                            .font(.headline)
//                        Text(errorMessage)
//                            .font(.body)
//                            .multilineTextAlignment(.center)
//                            .padding()
//                        
//                        Button("Try Again") {
////                            viewModel.fetchUsers()
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    }
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(radius: 5)
//                    .padding(.horizontal, 24)
//                }
//            }
//            .navigationTitle("Users")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
////                        viewModel.fetchUsers()
//                    }) {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                }
//            }
//        }
//        .onAppear {
////            viewModel.fetchUsers()
//        }
//    }
//}
//
//
//
//
////struct LoginView: View {
////    var body: some View {
////        VStack(spacing: 0) {
////            // Status bar area
////            HStack {
////                Text("9:41")
////                    .font(.system(size: 16, weight: .semibold))
////                
////                Spacer()
////                
////                HStack(spacing: 5) {
////                    // Cell signal
////                    Image(systemName: "antenna.radiowaves.left.and.right")
////                        .font(.system(size: 16))
////                    
////                    // WiFi
////                    Image(systemName: "wifi")
////                        .font(.system(size: 16))
////                    
////                    // Battery
////                    Image(systemName: "battery.100")
////                        .font(.system(size: 16))
////                }
////            }
////            .padding(.horizontal)
////            .padding(.top, 10)
////            
////            Spacer()
////                .frame(height: 160)
////            
////            // Logo
//////            LogoView()
//////                .frame(width: 85, height: 85)
////            
////            // App name
////            Text("LixeRead")
////                .font(.system(size: 36, weight: .bold))
////                .foregroundColor(Color(red: 0.27, green: 0.32, blue: 0.96))
////                .padding(.top, 8)
////            
////            Spacer()
////                .frame(height: 80)
////            
////            // Main content
////            VStack(spacing: 12) {
////                Text("Let's Get Started")
////                    .font(.system(size: 32, weight: .bold))
////                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.44))
////                
////                Text("Log in or join us")
////                    .font(.system(size: 18))
////                    .foregroundColor(Color.gray)
////            }
////            
////            Spacer()
////            
////            // Buttons
////            VStack(spacing: 16) {
////                Button(action: {
////                    // Log in action
////                }) {
////                    Text("Log in")
////                        .font(.system(size: 18, weight: .semibold))
////                        .foregroundColor(.white)
////                        .frame(maxWidth: .infinity)
////                        .frame(height: 54)
////                        .background(Color(red: 0.27, green: 0.32, blue: 0.96))
////                        .cornerRadius(27)
////                }
////                
////                Button(action: {
////                    // Sign in action
////                }) {
////                    Text("Sign in")
////                        .font(.system(size: 18, weight: .medium))
////                        .foregroundColor(Color(red: 0.27, green: 0.32, blue: 0.96))
////                }
////                .padding(.bottom, 40)
////            }
////            .padding(.horizontal, 24)
////            
////            // Home indicator
////            Rectangle()
////                .fill(Color.black)
////                .frame(width: 134, height: 5)
////                .cornerRadius(2.5)
////                .padding(.bottom, 8)
////        }
////        .frame(maxWidth: .infinity, maxHeight: .infinity)
////        .background(Color.white)
////        .edgesIgnoringSafeArea(.all)
////    }
////}
//struct CreateUserView: View {
//    @StateObject private var viewModel = UserViewModel()
//    @State private var name = ""
//    @State private var email = ""
//    @State private var showAlert = false
//    @State private var isSuccess = false
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("User Information")) {
//                    TextField("Name", text: $name)
//                    TextField("Email", text: $email)
//                        .keyboardType(.emailAddress)
//                        .autocapitalization(.none)
//                }
//                
//                Section {
//                    Button("Create User") {
//                        guard !name.isEmpty, !email.isEmpty else { return }
//                        
//                        viewModel.createUser(name: name, email: email) { success in
//                            isSuccess = success
//                            showAlert = true
//                        }
//                    }
//                    .disabled(name.isEmpty || email.isEmpty || viewModel.isLoading)
//                }
//            }
//            .navigationTitle("Create User")
//            .alert(isPresented: $showAlert) {
//                Alert(
//                    title: Text(isSuccess ? "Success" : "Error"),
//                    message: Text(isSuccess ? "User created successfully" : viewModel.errorMessage ?? "An error occurred"),
//                    dismissButton: .default(Text("OK")) {
//                        if isSuccess {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                    }
//                )
//            }
//            .overlay(
//                viewModel.isLoading ? ProgressView().scaleEffect(1.5) : nil
//            )
//        }
//    }
//}
