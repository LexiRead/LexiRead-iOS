//
//  BooksScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/03/2025.
//

import SwiftUI

struct BooksScreen: View {
    @StateObject private var viewModel = BooksViewModel()
    @State private var selectedTab = 0
    @State private var showFilePicker = false
    
    // Main app color
    private let appBlueColor = Color(UIColor(red: 0.27, green: 0.27, blue: 0.94, alpha: 1.0))
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Navigation bar
                customNavigationBar
                
                // Tab Navigation
                tabNavigationBar
                
                // Content area
                contentArea
            }
            .overlay(floatingActionButton)
            .sheet(isPresented: $showFilePicker) {
                documentPickerView
            }
            .onAppear {
                viewModel.fetchBooks()
                viewModel.fetchPDFFiles()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Text("Books")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
                .foregroundColor(appBlueColor)
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Button(action: {
                // Search action
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(appBlueColor)
            }
            .padding(.trailing)
        }
        .padding(.vertical)
    }
    
    private var tabNavigationBar: some View {
        HStack(spacing: 0) {
            TabButton(text: "Lixe Books", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(text: "MY Files", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
        }
    }
    
    private var contentArea: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                booksGridView
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .padding()
            Spacer()
        }
    }
    
    private var booksGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if selectedTab == 0 {
                    // Lixe Books
                    ForEach(viewModel.books) { book in
                        NavigationLink(destination: PDFReaderView()) {
                            PDFCard(
                                title: book.title,
                                subtitle: book.author,
                                imageName: book.coverURL,
                                isPDF: false
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    // My Files
                    ForEach(viewModel.pdfFiles) { pdf in
                        NavigationLink(destination: PDFReaderView()) {
                            PDFCard(
                                title: pdf.filename,
                                subtitle: "",
                                imageName: "",
                                isPDF: true
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    private var floatingActionButton: some View {
        Group {
            if selectedTab == 1 {
                // FAB only visible in My Files tab
                FloatingActionButton(action: {
                    showFilePicker = true
                })
            }
        }
    }
    
    private var documentPickerView: some View {
        DocumentPickerView { url in
            // Process the picked document
            let securedURL = url.startAccessingSecurityScopedResource()
            defer {
                if securedURL {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Create a local copy of the file to work with it
            do {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                
                // Remove any existing file
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                // Copy the file to app's document directory
                try FileManager.default.copyItem(at: url, to: destinationURL)
                
                // Upload the file using the viewModel
                viewModel.uploadFile(url: destinationURL)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    BooksScreen()
}
