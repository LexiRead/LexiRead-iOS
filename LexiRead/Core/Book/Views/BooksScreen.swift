//
//  BooksScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/03/2025.
//

import SwiftUI
import UIKit
import Alamofire
import PDFKit

struct BooksScreen: View {
    // Use StateObject to ensure the view model persists between navigation
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
                // Only fetch if needed - not on every appear
                viewModel.fetchBooks() // Will only load if not already loaded
                viewModel.fetchPDFFiles() // Will only load if not already loaded
            }
            // Add pull-to-refresh functionality
            .refreshable {
                // Force reload on pull-to-refresh
                if selectedTab == 0 {
                    viewModel.fetchBooks(forceReload: true)
                } else {
                    viewModel.fetchPDFFiles(forceReload: true)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
                .foregroundColor(.primary900)
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Button(action: {
                // Search action
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.primary900)
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
            if viewModel.isLoading && viewModel.books.isEmpty && selectedTab == 0 {
                // Only show loading view if we're loading initial data
                loadingView
            } else if viewModel.isLoading && viewModel.pdfFiles.isEmpty && selectedTab == 1 {
                // Only show loading view if we're loading initial data
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                booksGridView
            }
        }
        .refreshable {
            // Force reload on pull-to-refresh
            if selectedTab == 0 {
                viewModel.fetchBooks(forceReload: true)
            } else {
                viewModel.fetchPDFFiles(forceReload: true)
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
    
    // Update how PDFCard is called in BooksScreen
    private var booksGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if selectedTab == 0 {
                    // Lixe Books
                    // In BooksScreen, update the NavigationLink for books
                    ForEach(viewModel.books) { book in
                        NavigationLink(
                            destination: LazyNavigationDestination(book: book)
                        ) {
                            PDFCard(
                                title: book.title,
                                subtitle: book.author,
                                imageURL: book.coverURL,
                                isPDF: false
                            )
                            .onAppear {
                                viewModel.checkIfNeedMoreBooks(for: book.id)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Show loading indicator at the end when loading more
                    if viewModel.isLoading && !viewModel.books.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                } else {
                    // My Files section (unchanged)
                    ForEach(viewModel.pdfFiles) { pdf in
                        NavigationLink(destination: PDFReaderView(pdfURL: getURLForPDF(pdf))) {
                            PDFCard(
                                title: pdf.filename,
                                subtitle: "",
                                imageURL: "",
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
    
    // Add this to the document picker handling in BooksScreen
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
                
                // Upload the file using the viewModel - now with author and description
                let authorName = "User" // You could add a form to collect this
                let description = "Uploaded on \(Date())" // You could add a form to collect this
                
                viewModel.uploadFile(url: destinationURL, author: authorName, description: description)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }
    }
}


//MARK: - view model
class BooksViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var pdfFiles: [PDFFile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Add this flag to track if books have been loaded
    private var hasLoadedBooks = false
    private var hasLoadedPDFs = false
    
    // No need for token with the public Gutendex API
    private let gutendexURL = "https://gutendex.com/books/?mime_type=application/pdf"
    private var currentPage = 1
    private var hasMorePages = true
    private var nextPageURL: String? = nil
    
    func fetchBooks(forceReload: Bool = false) {
        // Only fetch if we haven't loaded before or if forced
        if hasLoadedBooks && !forceReload {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // First load, clear existing data
        if forceReload {
            books = []
            currentPage = 1
            hasMorePages = true
            nextPageURL = nil
        }
        
        // Determine which URL to use
        let urlString = forceReload || nextPageURL == nil ? gutendexURL : nextPageURL!
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        // Simplified request - no auth needed for Gutendex
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                print("Network error: \(error)")
                self.errorMessage = "Network error: \(error.localizedDescription)"
                return
            }
            
            guard let data = data else {
                self.errorMessage = "No data received"
                return
            }
            
            do {
                // Parse the JSON response from Gutendex
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Extract next page URL
                    self.nextPageURL = json["next"] as? String
                    self.hasMorePages = self.nextPageURL != nil
                    
                    // Extract results array
                    guard let results = json["results"] as? [[String: Any]] else {
                        throw NSError(domain: "com.app.error", code: 100,
                                      userInfo: [NSLocalizedDescriptionKey: "Invalid results format"])
                    }
                    
                    // Process the books
                    var parsedBooks: [Book] = []
                    
                    for bookDict in results {
                        guard let id = bookDict["id"] as? Int,
                              let title = bookDict["title"] as? String,
                              let authors = bookDict["authors"] as? [[String: Any]],
                              let formats = bookDict["formats"] as? [String: String] else {
                            continue
                        }
                        
                        // Get cover image URL from formats
                        let coverURL = formats["image/jpeg"] ?? ""
                        
                        // Get PDF URL from formats
                        let pdfURL = formats["application/pdf"] ?? ""
                        
                        // Extract author names
                        let authorNames = authors.compactMap { $0["name"] as? String }.joined(separator: ", ")
                        
                        // Create download links
                        let downloadLinks = DownloadLinks(
                            pdf: pdfURL,
                            text_html: nil,
                            epub: formats["application/epub+zip"]
                        )
                        
                        // Create a book with extracted data
                        let book = Book(id: id, title: title, author: authorNames, coverURL: coverURL, downloadLinks: downloadLinks)
                        parsedBooks.append(book)
                    }
                    
                    // Update books array
                    DispatchQueue.main.async {
                        if forceReload {
                            self.books = parsedBooks
                        } else {
                            // Append to existing books for pagination
                            self.books.append(contentsOf: parsedBooks)
                        }
                        self.hasLoadedBooks = true
                    }
                    
                } else {
                    throw NSError(domain: "com.app.error", code: 100,
                                  userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
            } catch {
                print("Error parsing data: \(error)")
                self.errorMessage = "Failed to parse book data: \(error.localizedDescription)"
            }
        }.resume()
    }
    
    // Add a method to load more books
    func loadMoreBooks() {
        guard !isLoading && hasMorePages && nextPageURL != nil else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Use the next page URL from the API
        guard let url = URL(string: nextPageURL!) else {
            self.errorMessage = "Invalid next page URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                print("Network error: \(error)")
                self.errorMessage = "Network error: \(error.localizedDescription)"
                return
            }
            
            guard let data = data else {
                self.errorMessage = "No data received"
                return
            }
            
            do {
                // Parse the JSON response from Gutendex
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Extract next page URL
                    self.nextPageURL = json["next"] as? String
                    self.hasMorePages = self.nextPageURL != nil
                    
                    // Extract results array
                    guard let results = json["results"] as? [[String: Any]] else {
                        throw NSError(domain: "com.app.error", code: 100,
                                      userInfo: [NSLocalizedDescriptionKey: "Invalid results format"])
                    }
                    
                    // Process the books
                    var newBooks: [Book] = []
                    
                    for bookDict in results {
                        guard let id = bookDict["id"] as? Int,
                              let title = bookDict["title"] as? String,
                              let authors = bookDict["authors"] as? [[String: Any]],
                              let formats = bookDict["formats"] as? [String: String] else {
                            continue
                        }
                        
                        // Get cover image URL from formats
                        let coverURL = formats["image/jpeg"] ?? ""
                        
                        // Get PDF URL from formats
                        let pdfURL = formats["application/pdf"] ?? ""
                        
                        // Extract author names
                        let authorNames = authors.compactMap { $0["name"] as? String }.joined(separator: ", ")
                        
                        // Create download links
                        let downloadLinks = DownloadLinks(
                            pdf: pdfURL,
                            text_html: nil,
                            epub: formats["application/epub+zip"]
                        )
                        
                        // Create a book with extracted data
                        let book = Book(id: id, title: title, author: authorNames, coverURL: coverURL, downloadLinks: downloadLinks)
                        newBooks.append(book)
                    }
                    
                    // Update books array by appending
                    DispatchQueue.main.async {
                        // Create a copy first to maintain scroll position
                        var updatedBooks = self.books
                        updatedBooks.append(contentsOf: newBooks)
                        self.books = updatedBooks
                    }
                } else {
                    throw NSError(domain: "com.app.error", code: 100,
                                  userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
            } catch {
                print("Error parsing data: \(error)")
                self.errorMessage = "Failed to parse book data: \(error.localizedDescription)"
            }
        }.resume()
    }
    
    // Helper to check if we need to load more
    func checkIfNeedMoreBooks(for bookID: Int) {
        let thresholdIndex = max(0, books.count - 5)
        
        if let index = books.firstIndex(where: { $0.id == bookID }),
           index >= thresholdIndex && !isLoading && hasMorePages {
            loadMoreBooks()
        }
    }
    
    // Keeping the PDF Files methods the same
    func fetchPDFFiles(forceReload: Bool = false) {
        // Only fetch if we haven't loaded before or if forced
        if hasLoadedPDFs && !forceReload {
            return
        }
        
        // Load files from UserDefaults for offline access
        loadPDFFilesFromUserDefaults()
        
        self.hasLoadedPDFs = true
    }
    
    // Upload a file to local storage
    func uploadFile(url: URL, author: String = "User", description: String = "Uploaded document") {
        isLoading = true
        errorMessage = nil
        
        // Add a local copy to our list
        let localPDF = PDFFile(
            id: Int.random(in: 10000...99999), // Temporary ID
            title: url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: ""),
            filename: url.lastPathComponent,
            fileURL: url.path,
            author: author,
            description: description,
            fileType: mimeType(for: url),
            createdAt: ISO8601DateFormatter().string(from: Date()),
            isLocalFile: true
        )
        
        DispatchQueue.main.async {
            self.pdfFiles.append(localPDF)
            self.savePDFFilesToUserDefaults()
            self.isLoading = false
        }
        
        // Copy the file to app documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            // Remove any existing file
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy to permanent location
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("File saved successfully to: \(destinationURL.path)")
        } catch {
            print("Error saving file: \(error.localizedDescription)")
            self.errorMessage = "Error saving file: \(error.localizedDescription)"
        }
    }
    
    // Helper method to determine MIME type of a file
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension
        
        switch pathExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "txt":
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
    
    // Update UserDefaults methods to handle the PDFFile structure
    private func savePDFFilesToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(pdfFiles) {
            UserDefaults.standard.set(encoded, forKey: "savedPDFFiles")
        }
    }
    
    private func loadPDFFilesFromUserDefaults() {
        if let savedPDFs = UserDefaults.standard.data(forKey: "savedPDFFiles") {
            let decoder = JSONDecoder()
            if let loadedPDFs = try? decoder.decode([PDFFile].self, from: savedPDFs) {
                pdfFiles = loadedPDFs
            }
        }
    }
    
    // This function is still needed for the LazyNavigationDestination
    func downloadBookPDF(for book: Book, completion: @escaping (URL?) -> Void) {
        // Get the PDF download link
        guard let downloadLinks = book.downloadLinks,
              let pdfLink = downloadLinks.pdf else {
            print("No PDF download link available for book: \(book.title)")
            completion(nil)
            return
        }
        
        // Clean up the URL
        let urlString = pdfLink
        
        // Debug print
        print("PDF download URL: \(urlString)")
        
        // Create a filename for the book
        let sanitizedTitle = book.title.replacingOccurrences(of: " ", with: "_")
                                       .replacingOccurrences(of: "/", with: "-")
                                       .replacingOccurrences(of: ":", with: "_")
        let filename = "book_\(book.id)_\(sanitizedTitle).pdf"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(filename)
        
        // Check if we already downloaded this book
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64) ?? 0
            print("Book already downloaded: \(filename), size: \(fileSize) bytes")
            
            if fileSize > 1000 {
                // If file exists and has reasonable size, use it
                completion(destinationURL)
                return
            } else {
                // Small or corrupt file, delete and redownload
                try? FileManager.default.removeItem(at: destinationURL)
                print("Deleted small or corrupt file")
            }
        }
        
        // Create URL
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        print("Starting download from: \(url)")
        
        // Download the file
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let tempURL = tempURL else {
                print("No temporary URL provided")
                completion(nil)
                return
            }
            
            do {
                // If the destination file already exists, remove it first
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                // Copy the temporary file to our destination
                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
                print("File downloaded successfully to: \(destinationURL.path)")
                
                // Verify the file is valid
                let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
                if let fileSize = attributes[.size] as? Int64, fileSize > 1000 {
                    print("Valid file with size: \(fileSize) bytes")
                    DispatchQueue.main.async {
                        completion(destinationURL)
                    }
                } else {
                    print("Downloaded file is too small")
                    try FileManager.default.removeItem(at: destinationURL)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Error saving file: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}

#Preview {
    BooksScreen()
}

private func getURLForPDF(_ pdf: PDFFile) -> URL? {
    // If it's a file we just added, the fileURL might be the local path
    if pdf.fileURL.starts(with: "/") {
        return URL(fileURLWithPath: pdf.fileURL)
    }
    
    // If it's a remote URL, check if we've already downloaded it
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let localURL = documentsDirectory.appendingPathComponent(pdf.filename)
    
    if FileManager.default.fileExists(atPath: localURL.path) {
        return localURL
    }
    
    return nil
}



// Add this function to BooksScreen
private func getBookPDFURL(_ book: Book) -> URL? {
    // First, check if there's a download_links.text_html property
    // and try to download the PDF
    if let htmlLink = book.downloadLinks?.text_html,
       let url = URL(string: htmlLink) {
        return downloadAndGetPDFURL(from: url, filename: "\(book.id)_\(book.title).pdf")
    }
    
    // Fallback to a sample PDF if no download link is available
    return Bundle.main.url(forResource: "draft", withExtension: "pdf")
}

// Helper method to download PDF and get local URL
private func downloadAndGetPDFURL(from remoteURL: URL, filename: String) -> URL? {
    // Create a local URL for the PDF
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let localURL = documentsDirectory.appendingPathComponent(filename)
    
    // Check if we already have the file
    if FileManager.default.fileExists(atPath: localURL.path) {
        return localURL
    }
    
    // If not, start a download (synchronously for simplicity)
    let semaphore = DispatchSemaphore(value: 0)
    var downloadedURL: URL? = nil
    
    let task = URLSession.shared.downloadTask(with: remoteURL) { tempURL, response, error in
        defer {
            semaphore.signal()
        }
        
        guard let tempURL = tempURL, error == nil else {
            print("Error downloading PDF: \(error?.localizedDescription ?? "unknown")")
            return
        }
        
        do {
            // If file already exists, remove it
            if FileManager.default.fileExists(atPath: localURL.path) {
                try FileManager.default.removeItem(at: localURL)
            }
            
            // Move the temporary file to our permanent location
            try FileManager.default.moveItem(at: tempURL, to: localURL)
            print("Successfully downloaded PDF to: \(localURL.path)")
            downloadedURL = localURL
        } catch {
            print("Error saving downloaded PDF: \(error.localizedDescription)")
        }
    }
    
    task.resume()
    
    // Wait for the download with a timeout
    let timeout = DispatchTime.now() + .seconds(10)
    if semaphore.wait(timeout: timeout) == .timedOut {
        print("PDF download timed out")
        return Bundle.main.url(forResource: "draft", withExtension: "pdf")
    }
    
    return downloadedURL ?? Bundle.main.url(forResource: "draft", withExtension: "pdf")
}






















//MARK: - models

struct Book: Identifiable, Decodable {
    var id: Int
    let title: String
    let author: String
    let coverURL: String
    let downloadLinks: DownloadLinks?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case authors
        case coverURL = "cover_url"
        case downloadLinks = "download_links"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        // Extract author names
        let authors = try container.decode([Author].self, forKey: .authors)
        author = authors.map { $0.name }.joined(separator: ", ")
        
        coverURL = try container.decode(String.self, forKey: .coverURL)
        downloadLinks = try? container.decodeIfPresent(DownloadLinks.self, forKey: .downloadLinks)
    }
    
    // Manual initializer for testing or fallback
    init(id: Int, title: String, author: String, coverURL: String, downloadLinks: DownloadLinks? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.coverURL = coverURL
        self.downloadLinks = downloadLinks
    }
}

struct DownloadLinks: Codable {
    let pdf: String?
    let text_html: String?
    let epub: String?
    
    enum CodingKeys: String, CodingKey {
        case pdf = "application/pdf"
        case text_html = "text/html"
        case epub = "application/epub+zip"
    }
}

// Add necessary supporting models
struct Author: Codable {
    let name: String
    let birth_year: Int?
    let death_year: Int?
}

struct BookResponse: Decodable {
    let data: BookData
}

struct BookData: Decodable {
    let current_page: Int
    let next_page: Int?
    let previous_page: Int?
    let results: [Book]
    
    // Custom decoding to handle string values for page numbers
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle cases where page numbers might be strings
        if let currentPageInt = try? container.decode(Int.self, forKey: .current_page) {
            current_page = currentPageInt
        } else if let currentPageString = try? container.decode(String.self, forKey: .current_page),
                  let pageInt = Int(currentPageString) {
            current_page = pageInt
        } else {
            current_page = 1 // Default
        }
        
        // Similar handling for next_page
        if let nextPageInt = try? container.decode(Int.self, forKey: .next_page) {
            next_page = nextPageInt
        } else if let nextPageString = try? container.decode(String.self, forKey: .next_page),
                  let pageInt = Int(nextPageString) {
            next_page = pageInt
        } else {
            next_page = nil
        }
        
        // And for previous_page
        if let prevPageInt = try? container.decode(Int.self, forKey: .previous_page) {
            previous_page = prevPageInt
        } else if let prevPageString = try? container.decode(String.self, forKey: .previous_page),
                  let pageInt = Int(prevPageString) {
            previous_page = pageInt
        } else {
            previous_page = nil
        }
        
        // Results array
        results = try container.decode([Book].self, forKey: .results)
    }
    
    enum CodingKeys: String, CodingKey {
        case current_page, next_page, previous_page, results
    }
}


// First, update the PDFFile struct to better handle local vs remote files
struct PDFFile: Identifiable, Codable {
    var id: Int
    let filename: String
    var fileURL: String
    let title: String
    let author: String
    let description: String
    let fileType: String
    let coverURL: String
    let createdAt: String
    var isLocalFile: Bool  // Flag to indicate if this is a local or remote file
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case description
        case fileURL = "file_url"
        case filename = "file_name"
        case fileType = "file_type"
        case coverURL = "cover_url"
        case createdAt = "created_at"
        case isLocalFile
    }
    
    // Add a custom initializer for local files
    init(id: Int = 0, title: String, filename: String, fileURL: String, author: String = "",
         description: String = "", fileType: String = "application/pdf",
         coverURL: String = "", createdAt: String = "", isLocalFile: Bool = false) {
        self.id = id
        self.title = title
        self.filename = filename
        self.fileURL = fileURL
        self.author = author
        self.description = description
        self.fileType = fileType
        self.coverURL = coverURL
        self.createdAt = createdAt
        self.isLocalFile = isLocalFile
    }
}

// Response structure for document list
struct DocumentResponse: Decodable {
    let data: [PDFFile]
}

// Response structure for single document
struct SingleDocumentResponse: Decodable {
    let data: PDFFile
}







struct LazyNavigationDestination: View {
    let book: Book
    @State private var pdfURL: URL? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @StateObject private var viewModel = BooksViewModel()
    
    var body: some View {
        ZStack {
            if let url = pdfURL {
                PDFReaderView(pdfURL: url)
                    .onAppear {
                        print("Opening PDF at: \(url.path)")
                        // Verify file exists at path
                        let exists = FileManager.default.fileExists(atPath: url.path)
                        print("File exists: \(exists), size: \(getFileSize(url: url)) bytes")
                    }
            } else if isLoading {
                VStack {
                    ProgressView("Preparing PDF...")
                        .padding()
                    
                    if let message = errorMessage {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
            } else {
                VStack {
                    Text("Could not load PDF")
                        .foregroundColor(.red)
                        .padding()
                    
                    if let error = errorMessage {
                        Text("Error: \(error)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button("Use Sample PDF") {
                        if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
                            pdfURL = sampleURL
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            if pdfURL == nil {
                convertHTMLAndLoadPDF()
            }
        }
    }
    
    private func getFileSize(url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            print("Error getting file size: \(error)")
            return 0
        }
    }
    
//    private func checkAndLoadPDF() {
//         isLoading = true
//         errorMessage = nil
//         
//         // Use the improved download method
//         viewModel.fixedDownloadBookPDF(for: book) { url in
//             isLoading = false
//             
//             if let url = url {
//                 pdfURL = url
//             } else {
//                 errorMessage = "Could not download PDF"
//                 
//                 // Try to fall back to sample PDF
//                 if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
//                     pdfURL = sampleURL
//                 }
//             }
//         }
//     }
    
    private func downloadPDF() {
        print("Downloading PDF for: \(book.title)")
        if let links = book.downloadLinks {
            print("Available links: PDF=\(links.pdf ?? "none"), HTML=\(links.text_html ?? "none")")
        } else {
            print("No download links available")
        }
        
        viewModel.downloadBookPDF(for: book) { url in
            isLoading = false
            
            if let url = url {
                pdfURL = url
                print("Successfully set PDF URL to: \(url.path)")
            } else {
                errorMessage = "Failed to download PDF"
                print("Failed to download PDF for: \(book.title)")
                
                // Try to fall back to the sample PDF
                if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
                    print("Falling back to sample PDF: \(sampleURL.path)")
                    pdfURL = sampleURL
                } else {
                    print("Could not find sample PDF 'draft.pdf'")
                }
            }
        }
    }
}



// This code doesn't change your UI but fixes the PDF loading functionality
extension BooksViewModel {
    
    // This is the improved download method that handles HTML links properly
    func improvedDownloadBookPDF(for book: Book, completion: @escaping (URL?) -> Void) {
        print("Starting improved download for: \(book.title)")
        
        // First check if we already have the PDF locally
        let sanitizedTitle = book.title.replacingOccurrences(of: " ", with: "_")
                                     .replacingOccurrences(of: "/", with: "-")
                                     .replacingOccurrences(of: ":", with: "_")
        let filename = "book_\(book.id)_\(sanitizedTitle).pdf"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: localURL.path)[.size] as? Int64) ?? 0
            print("Found existing PDF at: \(localURL.path), size: \(fileSize) bytes")
            
            if fileSize > 1000 {
                // Test if it's a valid PDF
                if let _ = PDFDocument(url: localURL) {
                    print("Valid local PDF found, using it")
                    completion(localURL)
                    return
                } else {
                    // Invalid PDF, delete it
                    try? FileManager.default.removeItem(at: localURL)
                    print("Invalid local PDF found, deleted it")
                }
            }
        }
        
        // Check available download links
        guard let downloadLinks = book.downloadLinks else {
            print("No download links available for book: \(book.title)")
            useFallbackPDF(completion: completion)
            return
        }
        
        print("Available links: PDF=\(downloadLinks.pdf ?? "none"), HTML=\(downloadLinks.text_html ?? "none")")
        
        // Check for PDF link first (direct PDF file)
        if let pdfURLString = downloadLinks.pdf, !pdfURLString.isEmpty,
            let pdfURL = URL(string: pdfURLString) {
            
            // If URL ends with .pdf, we can download directly
            if pdfURLString.lowercased().hasSuffix(".pdf") {
                downloadAndProcessPDF(from: pdfURL, to: localURL, completion: completion)
                return
            }
        }
        
        // Check for HTML link with PDF conversion
        if let htmlURLString = downloadLinks.text_html, !htmlURLString.isEmpty,
            let htmlURL = URL(string: htmlURLString) {
            
            // For HTML links, we need to fetch the HTML and attempt to find a PDF link inside
            convertHTMLToPDF(from: htmlURL, to: localURL, book: book, completion: completion)
            return
        }
        
        // If no valid links found, use fallback
        print("No valid download links found for book: \(book.title)")
        useFallbackPDF(completion: completion)
    }
    
    // Helper to download and process a PDF file
    private func downloadAndProcessPDF(from remoteURL: URL, to localURL: URL, completion: @escaping (URL?) -> Void) {
        print("Downloading PDF from direct URL: \(remoteURL)")
        
        let request = URLRequest(url: remoteURL)
        
        URLSession.shared.downloadTask(with: request) { tempURL, response, error in
            // Handle errors
            if let error = error {
                print("PDF download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.useFallbackPDF(completion: completion)
                }
                return
            }
            
            guard let tempURL = tempURL else {
                print("No temporary URL provided")
                DispatchQueue.main.async {
                    self.useFallbackPDF(completion: completion)
                }
                return
            }
            
            do {
                // Remove any existing file
                if FileManager.default.fileExists(atPath: localURL.path) {
                    try FileManager.default.removeItem(at: localURL)
                }
                
                // Copy to permanent location
                try FileManager.default.copyItem(at: tempURL, to: localURL)
                print("PDF downloaded to: \(localURL.path)")
                
                // Verify it's a valid PDF
                if let pdfDocument = PDFDocument(url: localURL),
                   pdfDocument.pageCount > 0 {
                    print("Downloaded valid PDF with \(pdfDocument.pageCount) pages")
                    DispatchQueue.main.async {
                        completion(localURL)
                    }
                } else {
                    print("Downloaded file is not a valid PDF")
                    try? FileManager.default.removeItem(at: localURL)
                    DispatchQueue.main.async {
                        self.useFallbackPDF(completion: completion)
                    }
                }
            } catch {
                print("Error saving PDF: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.useFallbackPDF(completion: completion)
                }
            }
        }.resume()
    }
    
    // Helper to find PDF link in HTML content and download it
    private func convertHTMLToPDF(from htmlURL: URL, to localURL: URL, book: Book, completion: @escaping (URL?) -> Void) {
        print("Fetching HTML page to find PDF link: \(htmlURL)")
        
        let task = URLSession.shared.dataTask(with: htmlURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching HTML: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.useFallbackPDF(completion: completion)
                }
                return
            }
            
            guard let data = data,
                  let htmlString = String(data: data, encoding: .utf8) else {
                print("Could not convert HTML data to string")
                DispatchQueue.main.async {
                    self.useFallbackPDF(completion: completion)
                }
                return
            }
            
            // Look for PDF download links in the HTML
            // Project Gutenberg typically has links like "download.pdf" or ".pdf" in their HTML
            if let pdfURLString = self.extractPDFURLFromHTML(htmlString, baseURL: htmlURL) {
                print("Found PDF URL in HTML: \(pdfURLString)")
                
                if let pdfURL = URL(string: pdfURLString) {
                    self.downloadAndProcessPDF(from: pdfURL, to: localURL, completion: completion)
                } else {
                    print("Invalid PDF URL extracted from HTML")
                    DispatchQueue.main.async {
                        self.useFallbackPDF(completion: completion)
                    }
                }
            } else {
                print("No PDF link found in HTML")
                
                // For Project Gutenberg books, we can try a known pattern for PDF links
                if htmlURL.absoluteString.contains("gutenberg.org/ebooks/") {
                    let bookIDString = htmlURL.absoluteString.components(separatedBy: "/ebooks/")[1].components(separatedBy: ".")[0]
                    
                    if let bookID = Int(bookIDString) {
                        // Try the direct PDF URL pattern for Project Gutenberg
                        let directPDFURLString = "https://www.gutenberg.org/files/\(bookID)/\(bookID)-pdf.pdf"
                        print("Trying direct Gutenberg PDF URL: \(directPDFURLString)")
                        
                        if let directPDFURL = URL(string: directPDFURLString) {
                            self.downloadAndProcessPDF(from: directPDFURL, to: localURL, completion: completion)
                            return
                        }
                    }
                }
                
                print("Could not find or construct PDF URL from HTML page")
                DispatchQueue.main.async {
                    self.useFallbackPDF(completion: completion)
                }
            }
        }
        
        task.resume()
    }
    
    // Helper to extract PDF URL from HTML content
    private func extractPDFURLFromHTML(_ html: String, baseURL: URL) -> String? {
        // Look for various patterns of PDF links in the HTML
        
        // Most common pattern: href="...pdf"
        let pdfRegexPatterns = [
            "href=\"([^\"]+\\.pdf)\"",
            "href='([^']+\\.pdf)'",
            "data-link=\"([^\"]+\\.pdf)\"",
            "url\\(([^)]+\\.pdf)\\)"
        ]
        
        for pattern in pdfRegexPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count)) {
                
                if let range = Range(match.range(at: 1), in: html) {
                    let urlString = String(html[range])
                    
                    // Handle relative URLs
                    if urlString.starts(with: "/") || !urlString.contains("://") {
                        return URL(string: urlString, relativeTo: baseURL)?.absoluteString
                    }
                    
                    return urlString
                }
            }
        }
        
        // Specific check for Gutenberg books
        if baseURL.absoluteString.contains("gutenberg.org/ebooks/") {
            // Look for download links section
            if let downloadsStartRange = html.range(of: "Download This eBook"),
               let downloadsEndRange = html.range(of: "Powered by", options: [], range: downloadsStartRange.upperBound..<html.endIndex) {
                
                let downloadsSection = html[downloadsStartRange.upperBound..<downloadsEndRange.lowerBound]
                
                // Look for PDF links in this section
                if let pdfLinkRange = downloadsSection.range(of: "href=\"([^\"]+\\.pdf)\"", options: .regularExpression) {
                    let linkSubstring = downloadsSection[pdfLinkRange]
                    let urlString = linkSubstring.replacingOccurrences(of: "href=\"", with: "").replacingOccurrences(of: "\"", with: "")
                    
                    // Handle relative URLs
                    if urlString.starts(with: "/") {
                        return URL(string: urlString, relativeTo: baseURL)?.absoluteString
                    }
                    
                    return urlString
                }
            }
        }
        
        return nil
    }
    
    // Helper to use fallback PDF if actual book PDF not available
    private func useFallbackPDF(completion: @escaping (URL?) -> Void) {
        print("Using fallback sample PDF")
        
        if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
            print("Fallback PDF found: \(sampleURL.path)")
            completion(sampleURL)
        } else {
            print("Fallback PDF not found")
            completion(nil)
        }
    }
}

// Just modify this part of LazyNavigationDestination without changing the structure
// Extension to LazyNavigationDestination to use the HTML-to-PDF converter
extension LazyNavigationDestination {
    // New method to convert HTML to PDF and display it
    func convertHTMLAndLoadPDF() {
        isLoading = true
        errorMessage = nil
        
        print("Starting HTML conversion for book: \(book.title)")
        
        viewModel.convertAndOpenBookPDF(for: book) { url in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let url = url {
                    self.pdfURL = url
                    print("PDF ready at: \(url.path)")
                } else {
                    self.errorMessage = "Could not create PDF"
                }
            }
        }
    }
}
