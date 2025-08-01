
//
//  BooksScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/03/2025.
//
import UIKit
import SwiftUI
import Combine
import PDFKit
import AVFoundation

// MARK: - Models

struct Author: Codable {
    let name: String
    let birthYear: Int?
    let deathYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"
        case deathYear = "death_year"
    }
    
    init(name: String, birthYear: Int? = nil, deathYear: Int? = nil) {
        self.name = name
        self.birthYear = birthYear
        self.deathYear = deathYear
    }
}

struct PDFFile: Identifiable, Codable {
    let id: Int
    let title: String
    let author: String
    let description: String?  // Changed to optional
    let fileURL: String
    let filename: String
    let fileType: String
    let coverURL: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, author, description
        case fileURL = "file_url"
        case filename = "file_name"
        case fileType = "file_type"
        case coverURL = "cover_url"
        case createdAt = "created_at"
    }
}


struct DocumentResponse: Codable {
    let data: [PDFFile]
}

struct PDFFileResponse: Codable {
    let data: PDFFile
}


struct PDFModel: Identifiable {
    let id = UUID()
    let url: URL?
    let fileName: String
    var extractedText: String = ""
    var pageCount: Int = 0
}

struct TranslationResult {
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
}

// MARK: - Services
// MARK: - Updated Models for Internal API
// MARK: - Updated Models for Internal API
struct Book: Identifiable, Codable {
    let id: Int
    let title: String
    let author: String
    let coverURL: String
    let downloadLinks: DownloadLinks?
    
    enum CodingKeys: String, CodingKey {
        case id, title, authors
        case coverURL = "cover_url"
        case downloadLinks = "download_links"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        // Handle authors array - can be empty in some cases
        let authors = try container.decodeIfPresent([Author].self, forKey: .authors) ?? []
        author = authors.map { $0.name }.joined(separator: ", ")
        
        // Get cover URL directly
        coverURL = try container.decodeIfPresent(String.self, forKey: .coverURL) ?? ""
        
        // Get download links directly
        downloadLinks = try container.decodeIfPresent(DownloadLinks.self, forKey: .downloadLinks)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        
        // For encoding, we'll create a simple author array with just the name
        let authorNames = author.components(separatedBy: ", ")
        let authors = authorNames.map { Author(name: $0, birthYear: nil, deathYear: nil) }
        try container.encode(authors, forKey: .authors)
        
        try container.encodeIfPresent(coverURL, forKey: .coverURL)
        try container.encodeIfPresent(downloadLinks, forKey: .downloadLinks)
    }
    
    init(id: Int, title: String, author: String, coverURL: String, downloadLinks: DownloadLinks? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.coverURL = coverURL
        self.downloadLinks = downloadLinks
    }
}

// Update DownloadLinks to match your API format
struct DownloadLinks: Codable {
    let pdf: String?
    let textHTML: String?
    let epub: String?
    
    enum CodingKeys: String, CodingKey {
        case pdf = "application/pdf"
        case textHTML = "text/html"
        case epub = "application/epub+zip"
    }
    
    init(pdf: String? = nil, textHTML: String? = nil, epub: String? = nil) {
        self.pdf = pdf
        self.textHTML = textHTML
        self.epub = epub
    }
}

// Update BooksResponse to match your API
struct BooksResponse: Codable {
    let data: BooksData
}

struct BooksData: Codable {
    let currentPage: Int
    let nextPage: Int?
    let previousPage: Int?
    let results: [Book]
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case previousPage = "previous_page"
        case results
    }
}

// Simplified BooksService
class BooksService {
    static let shared = BooksService()
    private let baseURL = "http://app.elfar5a.com/api/document/explore-gutendex"
    
    private init() {}
    
    func fetchBooks(nextPageURL: String? = nil) -> AnyPublisher<BooksResponse, APIError> {
        let urlString: String
        if let nextPageURL = nextPageURL {
            urlString = nextPageURL
        } else {
            urlString = "\(baseURL)?mime_type=application/pdf"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Fetch books with auth token: Bearer \(token)")
        }
        
        print("Fetching books from: \(urlString)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("Books API response status: \(httpResponse.statusCode)")
                
                // Print the actual response to see what's coming back
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("Books API response: \(responseStr)")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Books API error: \(errorString)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: BooksResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if error is DecodingError {
                    print("Decoding error: \(error)")
                    return APIError.invalidData
                } else {
                    return APIError.networkError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

class FileService {
    static let shared = FileService()
    private let baseURL = "http://app.elfar5a.com/api/document"
    
    private init() {}
    
    // Fetch all documents from API
    func fetchDocuments() -> AnyPublisher<[PDFFile], APIError> {
        guard let url = URL(string: "\(baseURL)/documents") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        // Add token if user is authenticated
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Fetch documents with auth token: Bearer \(token)")
        }
        
        print("Fetching documents from: \(url.absoluteString)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("API error: \(errorString)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: DocumentResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if error is DecodingError {
                    print("Decoding error: \(error)")
                    return APIError.invalidData
                } else {
                    return APIError.mapError(error)
                }
            }
            .map { $0.data }
            .eraseToAnyPublisher()
    }
    
    // Upload document to API
    // Upload document to API with improved error handling
    func uploadFile(fileURL: URL, title: String, author: String, description: String? = nil) -> AnyPublisher<PDFFile, APIError> {
        guard let url = URL(string: "\(baseURL)/store") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Verify file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at: \(fileURL.path)")
            return Fail(error: APIError.unknown("File not found")).eraseToAnyPublisher()
        }
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Using authorization token: \(token)")
        } else {
            print("Warning: No auth token available")
        }
        
        // Create form data
        var body = Data()
        
        // Add form fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"author\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(author)\r\n".data(using: .utf8)!)
        
        // Only add description if it's not nil
        if let description = description {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(description)\r\n".data(using: .utf8)!)
        }
        
        // Add file data
        do {
            let fileData = try Data(contentsOf: fileURL)
            print("Successfully read file data, size: \(fileData.count) bytes")
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType(for: fileURL))\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        } catch {
            print("Error reading file data: \(error)")
            return Fail(error: APIError.unknown("Error reading file")).eraseToAnyPublisher()
        }
        
        request.httpBody = body
        
        print("Uploading file to \(url.absoluteString), body size: \(body.count) bytes")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("Upload response status: \(httpResponse.statusCode)")
                
                // Print the response to check what we're getting
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("Response: \(responseStr)")
                    
                    // Check if the response is HTML instead of JSON
                    if responseStr.contains("<html") || responseStr.contains("<!DOCTYPE") || responseStr.starts(with: "<") {
                        throw APIError.serverError("Server returned HTML instead of JSON. There might be an authentication issue.")
                    }
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .decode(type: PDFFileResponse.self, decoder: JSONDecoder())
            .mapError { error in
                print("Upload error: \(error)")
                
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if let decodingError = error as? DecodingError {
                    print("JSON decoding error: \(decodingError)")
                    return APIError.invalidData
                }
                
                return APIError.mapError(error)
            }
            .map { $0.data }
            .handleEvents(receiveOutput: { [weak self] pdfFile in
                self?.saveFileLocally(pdfFile, originalURL: fileURL)
            })
            .eraseToAnyPublisher()
    }
    
    // Delete document from API
    func deleteDocument(id: Int) -> AnyPublisher<Bool, APIError> {
        guard let url = URL(string: "\(baseURL)/document/\(id)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("Deleting document with ID: \(id)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Delete error: \(errorString)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return true
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    // Save file locally
    func saveFileLocally(_ pdfFile: PDFFile, originalURL: URL) {
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(pdfFile.filename)
            
            print("Saving file locally: \(pdfFile.filename)")
            
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Check if original URL exists
            if FileManager.default.fileExists(atPath: originalURL.path) {
                try FileManager.default.copyItem(at: originalURL, to: destinationURL)
                print("File saved locally at: \(destinationURL.path)")
            } else if let remoteURL = URL(string: pdfFile.fileURL) {
                // If local file doesn't exist but remote URL is available, schedule a download
                print("Original file not available, will download from: \(remoteURL)")
                downloadFile(from: remoteURL, to: destinationURL) { success in
                    if success {
                        print("File downloaded and saved locally")
                    } else {
                        print("Failed to download file")
                    }
                }
            }
        } catch {
            print("Error saving file locally: \(error)")
        }
    }
    
    // Download file
    func downloadFile(from url: URL, to destinationURL: URL, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
                DispatchQueue.main.async { completion(true) }
            } catch {
                print("Error saving downloaded file: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }
        task.resume()
    }
    
    // Delete file locally
    func deleteFileLocally(_ pdfFile: PDFFile) {
        // First check if the file path is a direct path
        if FileManager.default.fileExists(atPath: pdfFile.fileURL) {
            do {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: pdfFile.fileURL))
                print("File deleted from direct path: \(pdfFile.fileURL)")
            } catch {
                print("Error deleting file from direct path: \(error)")
            }
        }
        
        // Also check documents directory with filename
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(pdfFile.filename)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            do {
                try FileManager.default.removeItem(at: localURL)
                print("File deleted locally: \(localURL.path)")
            } catch {
                print("Error deleting local file: \(error)")
            }
        }
    }
    
    // Get MIME type for a file
    func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "txt": return "text/plain"
        case "epub": return "application/epub+zip"
        default: return "application/octet-stream"
        }
    }
}

class PDFService {
    static let shared = PDFService()
    
    private init() {}
    
    func loadPDF(from url: URL) -> AnyPublisher<PDFModel, APIError> {
        return Future { promise in
            DispatchQueue.global(qos: .background).async {
                print("Loading PDF from: \(url.path)")
                guard FileManager.default.fileExists(atPath: url.path) else {
                    print("File does not exist at path: \(url.path)")
                    
                    // If URL is a remote URL, try to download it
                    if url.scheme == "http" || url.scheme == "https" {
                        self.downloadRemotePDF(from: url) { localURL in
                            if let localURL = localURL {
                                self.loadPDFDocument(from: localURL, promise: promise)
                            } else {
                                DispatchQueue.main.async {
                                    promise(.failure(APIError.invalidURL))
                                }
                            }
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        promise(.failure(APIError.invalidURL))
                    }
                    return
                }
                
                self.loadPDFDocument(from: url, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func loadPDFDocument(from url: URL, promise: @escaping (Result<PDFModel, APIError>) -> Void) {
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Could not create PDF document from URL: \(url.path)")
            DispatchQueue.main.async {
                promise(.failure(APIError.invalidData))
            }
            return
        }
        
        let extractedText = self.extractText(from: pdfDocument)
        let model = PDFModel(
            url: url,
            fileName: url.lastPathComponent,
            extractedText: extractedText,
            pageCount: pdfDocument.pageCount
        )
        
        print("Successfully loaded PDF with \(pdfDocument.pageCount) pages")
        DispatchQueue.main.async {
            promise(.success(model))
        }
    }
    
    private func downloadRemotePDF(from url: URL, completion: @escaping (URL?) -> Void) {
        print("Downloading remote PDF from: \(url)")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
                print("Remote PDF downloaded and saved to: \(destinationURL.path)")
                DispatchQueue.main.async { completion(destinationURL) }
            } catch {
                print("Error saving downloaded file: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }
    
    // REPLACE the existing downloadBookPDF method with this
    func downloadBookPDF(for book: Book) -> AnyPublisher<URL, APIError> {
        return Future { promise in
            // Check if already downloaded
            if let localURL = self.getLocalURLForBook(book) {
                print("Using cached book PDF: \(localURL.path)")
                DispatchQueue.main.async {
                    promise(.success(localURL))
                }
                return
            }
            
            let sanitizedTitle = book.title.replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "_")
            let filename = "book_\(book.id)_\(sanitizedTitle).pdf"
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(filename)
            
            // Try to download from available links
            if let pdfURL = book.downloadLinks?.pdf,
               let url = URL(string: pdfURL) {
                print("Downloading book PDF from: \(pdfURL)")
                self.downloadFile(from: url, to: destinationURL) { success in
                    if success {
                        // Save to UserDefaults
                        self.saveBookToDefaults(book, localURL: destinationURL)
                        DispatchQueue.main.async {
                            promise(.success(destinationURL))
                        }
                    } else {
                        self.useFallbackPDF(promise: promise)
                    }
                }
            } else {
                self.useFallbackPDF(promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func extractText(from pdfDocument: PDFDocument) -> String {
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            if let pageContent = page.string {
                extractedText += pageContent + "\n"
            }
        }
        
        return extractedText
    }
    
    private func downloadFile(from url: URL, to destinationURL: URL, completion: @escaping (Bool) -> Void) {
        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
                
                // Verify it's a valid PDF
                if let pdfDocument = PDFDocument(url: destinationURL), pdfDocument.pageCount > 0 {
                    print("Downloaded valid PDF with \(pdfDocument.pageCount) pages")
                    DispatchQueue.main.async { completion(true) }
                } else {
                    print("Downloaded PDF is invalid")
                    try? FileManager.default.removeItem(at: destinationURL)
                    DispatchQueue.main.async { completion(false) }
                }
            } catch {
                print("Error saving downloaded PDF: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
    
    private func useFallbackPDF(promise: @escaping (Result<URL, APIError>) -> Void) {
        if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
            print("Using sample PDF fallback")
            DispatchQueue.main.async {
                promise(.success(sampleURL))
            }
        } else {
            print("Sample PDF not found")
            DispatchQueue.main.async {
                promise(.failure(APIError.invalidData))
            }
        }
    }
    // Add these methods to PDFService class
    private func saveBookToDefaults(_ book: Book, localURL: URL) {
        // Save PDF file mapping
        var savedBooks = getSavedBooksFromDefaults()
        savedBooks[book.id] = localURL.lastPathComponent
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedBooks) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultKeys.downloadedBookPDFs)
        }
        
        // Also save book data
        saveBookDataToDefaults(book)
    }

     func getSavedBooksFromDefaults() -> [Int: String] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultKeys.downloadedBookPDFs) else {
            return [:]
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([Int: String].self, from: data)) ?? [:]
    }

     func getLocalURLForBook(_ book: Book) -> URL? {
        let savedBooks = getSavedBooksFromDefaults()
        guard let filename = savedBooks[book.id] else { return nil }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(filename)
        
        return FileManager.default.fileExists(atPath: localURL.path) ? localURL : nil
    }

     func saveBookDataToDefaults(_ book: Book) {
        var savedBooksData = getSavedBooksDataFromDefaults()
        
        // Add book if not already saved
        if !savedBooksData.contains(where: { $0.id == book.id }) {
            savedBooksData.append(book)
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(savedBooksData) {
                UserDefaults.standard.set(encoded, forKey: UserDefaultKeys.savedBooks)
            }
        }
    }

     func getSavedBooksDataFromDefaults() -> [Book] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultKeys.savedBooks) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([Book].self, from: data)) ?? []
    }
}

class TranslationService {
    static let shared = TranslationService()
    private let baseURL = "http://app.elfar5a.com/api/translate"
    var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // Real API implementation
    func translateText(_ text: String, sourceLanguage: String = "en", targetLanguage: String = "ar") -> AnyPublisher<TranslationResult, APIError> {
        // Create the URL
        guard let url = URL(string: "\(baseURL)/translate") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create the request body
        let parameters: [String: Any] = [
            "text": text,
            "target": "ar"  // Hard-coded to Arabic as requested
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return Fail(error: APIError.unknown("Failed to serialize translation request")).eraseToAnyPublisher()
        }
        
        print("Translating text: \(text)")
        
        // Make the network request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("Translation response status: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Translation error response: \(errorStr)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .tryMap { data -> TranslationResult in
                // Print the response for debugging
                let responseStr = String(data: data, encoding: .utf8) ?? "Unknown response"
                print("Translation response: \(responseStr)")
                
                // Parse the JSON response
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let translation = json["translation"] as? String else {
                    throw APIError.invalidData
                }
                
                // Create the translation result
                let result = TranslationResult(
                    originalText: text,
                    translatedText: translation,
                    sourceLanguage: sourceLanguage,
                    targetLanguage: targetLanguage
                )
                
                return result
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if let error = error as? DecodingError {
                    print("JSON parsing error: \(error)")
                    return APIError.invalidData
                }
                
                return APIError.mapError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // Fallback method for when the API fails
    func localTranslation(_ text: String, sourceLanguage: String = "en", targetLanguage: String = "ar") -> TranslationResult {
        // Simple mock translation for fallback
        return TranslationResult(
            originalText: text,
            translatedText: "ترجمة: \(text)",  // Just adding "translation:" in Arabic
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
    }
    
    
    func textToSpeech(text: String, language: String = "en") -> AnyPublisher<String, APIError> {
        // Create the URL
        guard let url = URL(string: "http://app.elfar5a.com/api/tspeech/tts") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create the request body
        let parameters: [String: Any] = [
            "text": text,
            "lang": language
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return Fail(error: APIError.unknown("Failed to serialize text-to-speech request")).eraseToAnyPublisher()
        }
        
        print("Requesting text-to-speech for: \(text)")
        
        // Make the network request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("TTS response status: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("TTS error response: \(errorStr)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .tryMap { data -> String in
                // Print the response for debugging
                let responseStr = String(data: data, encoding: .utf8) ?? "Unknown response"
                print("TTS response: \(responseStr)")
                
                // Parse the JSON response
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let audioURL = json["audio_url"] as? String else {
                    throw APIError.invalidData
                }
                
                return audioURL
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if let error = error as? DecodingError {
                    print("JSON parsing error: \(error)")
                    return APIError.invalidData
                }
                
                return APIError.mapError(error)
            }
            .eraseToAnyPublisher()
    }

    // Add this to play the audio from a URL
    func playAudio(from urlString: String, completion: @escaping () -> Void = {}) {
        AudioPlayerManager.shared.playAudio(from: urlString, completion: completion)
    }
    
    
    
    // New method specifically for TranslateScreen with dynamic target language
    func translateTextWithTarget(_ text: String, targetLanguage: String) -> AnyPublisher<TranslationResult, APIError> {
        // Create the URL
        guard let url = URL(string: "\(baseURL)/translate") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create the request body with dynamic target language
        let parameters: [String: Any] = [
            "text": text,
            "target": targetLanguage  // Use the provided target language
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return Fail(error: APIError.unknown("Failed to serialize translation request")).eraseToAnyPublisher()
        }
        
        print("Translating text: \(text) to \(targetLanguage)")
        
        // Make the network request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("Translation response status: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Translation error response: \(errorStr)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                return data
            }
            .tryMap { data -> TranslationResult in
                // Print the response for debugging
                let responseStr = String(data: data, encoding: .utf8) ?? "Unknown response"
                print("Translation response: \(responseStr)")
                
                // Parse the JSON response
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let translation = json["translation"] as? String else {
                    throw APIError.invalidData
                }
                
                // Create the translation result
                let result = TranslationResult(
                    originalText: text,
                    translatedText: translation,
                    sourceLanguage: "auto-detect", // Since backend auto-detects
                    targetLanguage: targetLanguage
                )
                
                return result
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if let error = error as? DecodingError {
                    print("JSON parsing error: \(error)")
                    return APIError.invalidData
                }
                
                return APIError.mapError(error)
            }
            .eraseToAnyPublisher()
    }
}


class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var completionHandler: (() -> Void)?
    
    private init() {}
    
    func playAudio(from urlString: String, completion: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid audio URL")
            completion()
            return
        }
        
        // Create player item
        playerItem = AVPlayerItem(url: url)
        
        // Create player
        player = AVPlayer(playerItem: playerItem)
        
        // Add observer for when playback ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Store completion handler
        completionHandler = completion
        
        // Ensure audio plays even when device is muted
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        // Start playing
        player?.play()
        
        print("Playing audio from: \(urlString)")
    }
    
    @objc private func playerDidFinishPlaying() {
        // Clean up
        cleanUp()
        
        // Call completion handler
        completionHandler?()
        completionHandler = nil
    }
    
    func stopPlayback() {
        player?.pause()
        cleanUp()
        completionHandler?()
        completionHandler = nil
    }
    
    private func cleanUp() {
        // Remove observer
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        // Clear player and item
        player = nil
        playerItem = nil
    }
}

// MARK: - ViewModels
class BooksViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var pdfFiles: [PDFFile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteAlert = false
    @Published var pdfToDelete: PDFFile?
    
    private var hasLoadedBooks = false
    private var hasLoadedPDFs = false
    private var nextPageURL: String?
    private var hasMorePages = true
    private var cancellables = Set<AnyCancellable>()
    
    func fetchBooksIfNeeded() {
        guard !hasLoadedBooks else { return }
        fetchBooks()
    }
    
    func fetchPDFFilesIfNeeded() {
        guard !hasLoadedPDFs else { return }
        fetchPDFFiles()
    }
    
//    func fetchBooks(forceReload: Bool = false) {
//        if forceReload {
//            books = []
//            nextPageURL = nil
//            hasMorePages = true
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        BooksService.shared.fetchBooks(nextPageURL: forceReload ? nil : nextPageURL)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    if case .failure(let error) = completion {
//                        print("Error fetching books: \(error)")
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] response in
////                    print("Successfully received \(response.results.count) books")
//                    self?.nextPageURL = response.next
//                    self?.hasMorePages = response.next != nil
//                    
//                    if forceReload {
//                        self?.books = response.results
//                    } else {
//                        self?.books.append(contentsOf: response.results)
//                    }
//                    self?.hasLoadedBooks = true
//                }
//            )
//            .store(in: &cancellables)
//    }
    
    
    
    // REPLACE the existing fetchBooks method with this
    func fetchBooks(forceReload: Bool = false) {
        // Don't clear books immediately when force reloading - wait to see if we can fetch new ones
        if forceReload {
            nextPageURL = nil
            hasMorePages = true
        }
        
        isLoading = true
        errorMessage = nil
        
        BooksService.shared.fetchBooks(nextPageURL: forceReload ? nil : nextPageURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Error fetching books: \(error)")
                        
                        // Get offline books
                        let offlineBooks = self?.getAllOfflineBooks() ?? []
                        
                        if offlineBooks.isEmpty {
                            // Only show error if no offline books are available
                            self?.errorMessage = error.localizedDescription
                            if forceReload {
                                self?.books = [] // Clear only if no offline books
                            }
                        } else {
                            // Show offline books instead of error
                            self?.books = offlineBooks
                            self?.errorMessage = nil
                            print("Showing \(offlineBooks.count) offline books")
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    print("Successfully received \(response.data.results.count) books")
                    self?.nextPageURL = response.data.nextPage != nil ? "http://app.elfar5a.com/api/document/explore-gutendx/?mime_type=application/pdf&page=\(response.data.nextPage!)" : nil
                    self?.hasMorePages = response.data.nextPage != nil
                    
                    // Now we can safely clear and replace with new data
                    if forceReload {
                        self?.books = response.data.results
                    } else {
                        self?.books.append(contentsOf: response.data.results)
                    }
                    self?.hasLoadedBooks = true
                    self?.errorMessage = nil // Clear any previous error
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchPDFFiles(forceReload: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        // Always load local files first
        loadPDFFilesFromUserDefaults()
        let localFiles = pdfFiles.filter { $0.id >= 100000 } // Keep local files
        
        // Then try to fetch from API
        FileService.shared.fetchDocuments()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Error fetching PDF files: \(error)")
                        
                        // Always keep local files, never show error for MY Files tab
                        self?.pdfFiles = localFiles
                        self?.errorMessage = nil // Don't show error message
                        print("Showing \(localFiles.count) local files (server unavailable)")
                    }
                },
                receiveValue: { [weak self] serverFiles in
                    print("Successfully received \(serverFiles.count) PDF files from server")
                    
                    if let self = self {
                        // Combine local files with server files
                        var combinedFiles = localFiles
                        combinedFiles.append(contentsOf: serverFiles)
                        
                        self.pdfFiles = combinedFiles
                        self.savePDFFilesToUserDefaults()
                        self.hasLoadedPDFs = true
                        self.errorMessage = nil
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // In BooksViewModel
    func uploadFile(url: URL) {
        print("Processing file: \(url.lastPathComponent)")
        
        // Verify the file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            errorMessage = "File not found: \(url.lastPathComponent)"
            return
        }
        
        // Get file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        print("File size: \(fileSize) bytes")
        
        if fileSize == 0 {
            errorMessage = "File is empty"
            return
        }
        
        // Generate a user-friendly title
        let fileName = url.deletingPathExtension().lastPathComponent
        let title = fileName.replacingOccurrences(of: "_", with: " ")
                             .replacingOccurrences(of: "-", with: " ")
        
        // Create a PDF file entry
        let newPDF = PDFFile(
            id: Int.random(in: 100000...999999),
            title: title,
            author: UserManager.shared.userName ?? "User",
            description: nil,
            fileURL: url.path,
            filename: url.lastPathComponent,
            fileType: FileService.shared.mimeType(for: url),
            coverURL: "",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        // Add to our collection
        pdfFiles.append(newPDF)
        savePDFFilesToUserDefaults()  // Make sure this is called
        
        print("Added local PDF file: \(title)")
    }

    // Improved fallback for local files
    private func createLocalOnlyFile(url: URL, title: String) {
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            // Make a local copy
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.copyItem(at: url, to: destinationURL)
                
                // Create a local PDF file entry
                let localPDF = PDFFile(
                    id: Int.random(in: 100000...999999),
                    title: title,
                    author: UserManager.shared.userName ?? "User",
                    description: nil,  // Use nil for description
                    fileURL: destinationURL.path,
                    filename: url.lastPathComponent,
                    fileType: FileService.shared.mimeType(for: url),
                    coverURL: "",
                    createdAt: ISO8601DateFormatter().string(from: Date())
                )
                
                pdfFiles.append(localPDF)
                savePDFFilesToUserDefaults()
                
                print("Created local file fallback")
                
                // Clear error message since we've provided a fallback
                errorMessage = nil
            } else {
                print("Original file not found at: \(url.path)")
            }
        } catch {
            print("Failed to create local file: \(error)")
        }
    }
    
    func deleteFile(pdfFile: PDFFile) {
        isLoading = true
        errorMessage = nil
        
        // Check if it's a local file (high ID) or server file
        let isLocalFile = pdfFile.id >= 100000
        
        if isLocalFile {
            // Local file - just remove from array and local storage
            print("Deleting local file: \(pdfFile.filename)")
            
            // Delete the file from local storage
            FileService.shared.deleteFileLocally(pdfFile)
            
            // Remove from array
            pdfFiles.removeAll { $0.id == pdfFile.id }
            
            // Save updated list to UserDefaults
            savePDFFilesToUserDefaults()
            
            isLoading = false
        } else {
            // Server file - try to delete from server first
            print("Deleting server file with ID: \(pdfFile.id)")
            
            FileService.shared.deleteDocument(id: pdfFile.id)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        
                        if case .failure(let error) = completion {
                            print("Server delete error: \(error)")
                            
                            // Even if server delete fails, remove locally
                            self?.pdfFiles.removeAll { $0.id == pdfFile.id }
                            FileService.shared.deleteFileLocally(pdfFile)
                            self?.savePDFFilesToUserDefaults()
                        }
                    },
                    receiveValue: { [weak self] success in
                        if success {
                            // Remove from local array
                            self?.pdfFiles.removeAll { $0.id == pdfFile.id }
                            
                            // Delete locally stored file
                            FileService.shared.deleteFileLocally(pdfFile)
                            
                            // Update UserDefaults
                            self?.savePDFFilesToUserDefaults()
                        } else {
                            // Even if server delete returns false, remove locally
                            self?.pdfFiles.removeAll { $0.id == pdfFile.id }
                            FileService.shared.deleteFileLocally(pdfFile)
                            self?.savePDFFilesToUserDefaults()
                        }
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    func confirmDelete(pdfFile: PDFFile) {
        pdfToDelete = pdfFile
        showDeleteAlert = true
    }
    
    func checkIfNeedMoreBooks(for bookID: Int) {
        let thresholdIndex = max(0, books.count - 5)
        
        if let index = books.firstIndex(where: { $0.id == bookID }),
           index >= thresholdIndex && !isLoading && hasMorePages {
            fetchBooks()
        }
    }
    
    private func savePDFFilesToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(pdfFiles) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultKeys.savedPDFFiles)
        }
    }
    
    private func loadPDFFilesFromUserDefaults() {
        if let savedPDFs = UserDefaults.standard.data(forKey: UserDefaultKeys.savedPDFFiles) {
            let decoder = JSONDecoder()
            if let loadedPDFs = try? decoder.decode([PDFFile].self, from: savedPDFs) {
                print("Loaded \(loadedPDFs.count) PDF files from UserDefaults")
                pdfFiles = loadedPDFs
            } else {
                print("Failed to decode PDF files from UserDefaults")
            }
        } else {
            print("No saved PDF files found in UserDefaults")
        }
    }
    
    // CHANGE from private to public
    func getOfflineBooks() -> [Book] {
        let savedBooks = getSavedBooksFromDefaults()
        let savedBooksData = getSavedBooksDataFromDefaults()
        
        var offlineBooks: [Book] = []
        
        // Get books from saved book data
        for bookData in savedBooksData {
            if let filename = savedBooks[bookData.id] {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let localURL = documentsDirectory.appendingPathComponent(filename)
                if FileManager.default.fileExists(atPath: localURL.path) {
                    offlineBooks.append(bookData)
                }
            }
        }
        
        return offlineBooks
    }
    
    // Add these methods to BooksViewModel class
    private func getAllOfflineBooks() -> [Book] {
        let savedBooks = getSavedBooksFromDefaults()
        let savedBooksData = getSavedBooksDataFromDefaults()
        
        var offlineBooks: [Book] = []
        
        // Get books from saved book data
        for bookData in savedBooksData {
            if let filename = savedBooks[bookData.id] {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let localURL = documentsDirectory.appendingPathComponent(filename)
                if FileManager.default.fileExists(atPath: localURL.path) {
                    offlineBooks.append(bookData)
                }
            }
        }
        
        return offlineBooks
    }

    private func getSavedBooksFromDefaults() -> [Int: String] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultKeys.downloadedBookPDFs) else {
            return [:]
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([Int: String].self, from: data)) ?? [:]
    }

    private func getSavedBooksDataFromDefaults() -> [Book] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultKeys.savedBooks) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([Book].self, from: data)) ?? []
    }
}

class PDFReaderViewModel: ObservableObject {
    @Published var pdfModel: PDFModel?
    @Published var selectedWord: String?
    @Published var translationResult: TranslationResult?
    @Published var isLoading = false
    @Published var isTranslating = false
    @Published var errorMessage: String?
    @Published var showTranslation = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadPDF(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        PDFService.shared.loadPDF(from: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] pdfModel in
                    self?.pdfModel = pdfModel
                }
            )
            .store(in: &cancellables)
    }
    
    func loadBookPDF(for book: Book) {
        isLoading = true
        errorMessage = nil
        
        PDFService.shared.downloadBookPDF(for: book)
            .flatMap { url in
                PDFService.shared.loadPDF(from: url)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] pdfModel in
                    self?.pdfModel = pdfModel
                }
            )
            .store(in: &cancellables)
    }
    
    func translateWord(_ word: String) {
        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        selectedWord = word
        isTranslating = true
        
        TranslationService.shared.translateText(word)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isTranslating = false
                    
                    if case .failure(let error) = completion {
                        print("Translation error: \(error)")
                        
                        // Use fallback local translation if API fails
                        let fallbackResult = TranslationService.shared.localTranslation(word)
                        self?.translationResult = fallbackResult
                        self?.showTranslation = true
                    }
                },
                receiveValue: { [weak self] result in
                    print("Received translation: \(result.translatedText)")
                    self?.translationResult = result
                    self?.showTranslation = true
                }
            )
            .store(in: &cancellables)
    }
    
    func dismissTranslation() {
        showTranslation = false
        selectedWord = nil
        translationResult = nil
    }
}

// MARK: - UI Components
struct BooksScreen: View {
    @StateObject private var viewModel = BooksViewModel()
    @State private var selectedTab = 0
    @State private var showFilePicker = false
    
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
                viewModel.fetchBooksIfNeeded()
                viewModel.fetchPDFFilesIfNeeded()
            }
            .refreshable {
                if selectedTab == 0 {
                    viewModel.fetchBooks(forceReload: true)
                } else {
                    viewModel.fetchPDFFiles(forceReload: true)
                }
            }
            .alert(isPresented: $viewModel.showDeleteAlert) {
                Alert(
                    title: Text("Delete File"),
                    message: Text("Are you sure you want to delete this file? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let pdfToDelete = viewModel.pdfToDelete {
                            viewModel.deleteFile(pdfFile: pdfToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: BackButton())
    }
    
    // MARK: - UI Components
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            Spacer()
            Text("Books")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary900)
            Spacer()
            
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
            if viewModel.isLoading && (selectedTab == 0 ? viewModel.books.isEmpty : viewModel.pdfFiles.isEmpty) {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    if selectedTab == 0 {
                        viewModel.fetchBooks(forceReload: true)
                    } else {
                        viewModel.fetchPDFFiles(forceReload: true)
                    }
                }
            } else {
                booksGridView
            }
        }
    }
    
    private var booksGridView: some View {
        Group {
            if selectedTab == 0 {
                // Books tab content
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        let booksToShow = viewModel.errorMessage != nil ? viewModel.getOfflineBooks() : viewModel.books
                        
                        ForEach(booksToShow) { book in
                            NavigationLink(
                                destination: PDFReaderView(book: book)
                            ) {
                                PDFCard(
                                    title: book.title,
                                    subtitle: book.author,
                                    imageURL: book.coverURL,
                                    isPDF: false
                                )
                                .onAppear {
                                    if viewModel.errorMessage == nil {
                                        viewModel.checkIfNeedMoreBooks(for: book.id)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if viewModel.isLoading && !viewModel.books.isEmpty && viewModel.errorMessage == nil {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        
                        if viewModel.errorMessage != nil && booksToShow.isEmpty {
                            Text("No offline books available")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
            } else {
                // PDF Files tab content
                if viewModel.pdfFiles.isEmpty && !viewModel.isLoading {
                    // Empty state - centered
                    VStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Files Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Text("Tap the + button to upload your first PDF file")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Files list
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.pdfFiles) { pdf in
                                PDFFileCard(
                                    pdf: pdf,
                                    onDelete: {
                                        viewModel.confirmDelete(pdfFile: pdf)
                                    },
                                    isLexiBooks: false
                                )
                            }
                            
                            if viewModel.isLoading && !viewModel.pdfFiles.isEmpty {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private var floatingActionButton: some View {
        Group {
            if selectedTab == 1 {
                FloatingActionButton(action: {
                    showFilePicker = true
                })
            }
        }
    }
    
    private var documentPickerView: some View {
        DocumentPickerView { url in
            viewModel.uploadFile(url: url)
        }
    }
}

// New component for PDF Files with delete option
struct PDFFileCard: View {
    let pdf: PDFFile
    let onDelete: () -> Void
    let isLexiBooks: Bool  // Add this parameter to track which tab is active
    
    var body: some View {
        NavigationLink(destination: PDFReaderView(pdfFile: pdf)) {
            ZStack(alignment: .topTrailing) {
                PDFCard(
                    title: pdf.title,
                    subtitle: isLexiBooks ? pdf.author : "",  // Only show author if in Lexi Books tab
                    imageURL: pdf.coverURL,
                    isPDF: true
                )
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .padding(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(isSelected ? .primary900 : .gray)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .fill(isSelected ? Color.primary900 : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PDFCard: View {
    let title: String
    let subtitle: String
    let imageURL: String
    let isPDF: Bool
    
    var body: some View {
        VStack {
            AsyncImage(url: getValidURL()) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: isPDF ? "doc.fill" : "book.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_):
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: isPDF ? "doc.fill" : "book.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(height: 160)
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // Helper function to ensure we have a valid URL
    private func getValidURL() -> URL? {
        guard !imageURL.isEmpty else { return nil }
        
        // Check if the URL has a proper scheme
        if let url = URL(string: imageURL) {
            return url
        }
        
        return nil
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.primary900)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button("Retry") {
                retryAction()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.primary900)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.7))
            )
        }
    }
}

// MARK: - PDF Reader Views
struct PDFReaderView: View {
    @StateObject private var viewModel = PDFReaderViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    let book: Book?
    let pdfFile: PDFFile?
    
    init(book: Book) {
        self.book = book
        self.pdfFile = nil
    }
    
    init(pdfFile: PDFFile) {
        self.book = nil
        self.pdfFile = pdfFile
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    loadContent()
                }
            } else if let pdfModel = viewModel.pdfModel {
                PDFContentView(
                    pdfModel: pdfModel,
                    onWordSelected: { word in
                        viewModel.translateWord(word)
                    }
                )
            } else {
                EmptyPDFView {
                    loadContent()
                }
            }
            
            // Translation Overlay
            if viewModel.showTranslation,
               let result = viewModel.translationResult {
                TranslationOverlayView(
                    translationResult: result,
                    isTranslating: viewModel.isTranslating,
                    onDismiss: {
                        viewModel.dismissTranslation()
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: BackButton())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                        .foregroundStyle(.darkerBlue)
                }
            }
        }
        .onAppear {
            loadContent()
        }
    }
    
    private func loadContent() {
        if let book = book {
            viewModel.loadBookPDF(for: book)
        } else if let pdfFile = pdfFile {
            let url = getURLForPDFFile(pdfFile)
            if let validURL = url {
                viewModel.loadPDF(from: validURL)
            } else {
                viewModel.errorMessage = "Could not locate PDF file"
            }
        }
    }
    
    private func getURLForPDFFile(_ pdfFile: PDFFile) -> URL? {
            // First check if the path is directly accessible
            let directPath = pdfFile.fileURL
            if FileManager.default.fileExists(atPath: directPath) {
                print("PDF found at direct path: \(directPath)")
                return URL(fileURLWithPath: directPath)
            }
            
            // Check for the file in the documents directory by filename
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let localPath = documentsDirectory.appendingPathComponent(pdfFile.filename)
            
            if FileManager.default.fileExists(atPath: localPath.path) {
                print("PDF found in documents directory: \(localPath.path)")
                return localPath
            }
            
            // If it's a remote URL, use that
            if pdfFile.fileURL.starts(with: "http") {
                print("Using remote URL: \(pdfFile.fileURL)")
                return URL(string: pdfFile.fileURL)
            }
            
            print("Could not find PDF file at any location")
            return nil
        }
}

struct PDFContentView: View {
    let pdfModel: PDFModel
    let onWordSelected: (String) -> Void
    
    var body: some View {
        VStack {
            if let url = pdfModel.url {
                EnhancedPDFView(
                    pdfURL: url,
                    onWordSelected: onWordSelected
                )
            } else {
                Text("No PDF content available")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
        }
    }
}

struct EmptyPDFView: View {
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No PDF Loaded")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Unable to load the PDF document")
                .font(.body)
                .foregroundColor(.gray)
            
            Button("Try Again") {
                retryAction()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.primary900)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - PDF Viewer Component (Updated for Continuous Scrolling)
struct EnhancedPDFView: UIViewRepresentable {
    let pdfURL: URL
    let onWordSelected: (String) -> Void
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Configure PDF View for continuous scrolling
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous  // Changed from .singlePage
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(false)  // Changed from true to false
        
        // Enable zooming
        pdfView.minScaleFactor = 0.8
        pdfView.maxScaleFactor = 3.0
        pdfView.scaleFactor = 1.0
        
        // Enable scrolling
        pdfView.isUserInteractionEnabled = true
        
        // Load document
        if let document = PDFDocument(url: pdfURL) {
            // Limit to first 5 pages for large documents
            if document.pageCount > 25 {
                let limitedDocument = PDFDocument()
                for i in 0..<min(25, document.pageCount) {
                    if let page = document.page(at: i) {
                        limitedDocument.insert(page, at: i)
                    }
                }
                pdfView.document = limitedDocument
            } else {
                pdfView.document = document
            }
            
            // Set initial scale to fit width properly
            DispatchQueue.main.async {
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            }
        }
        
        // Add gesture recognizers (unchanged)
        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTapGesture.numberOfTapsRequired = 2
        pdfView.addGestureRecognizer(doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        longPressGesture.minimumPressDuration = 0.5
        pdfView.addGestureRecognizer(longPressGesture)
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: EnhancedPDFView
        
        init(_ parent: EnhancedPDFView) {
            self.parent = parent
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            extractWordAtGesture(gesture)
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                extractWordAtGesture(gesture)
            }
        }
        
        private func extractWordAtGesture(_ gesture: UIGestureRecognizer) {
            guard let pdfView = gesture.view as? PDFView else { return }
            let point = gesture.location(in: pdfView)
            
            guard let page = pdfView.page(for: point, nearest: true) else { return }
            let pagePoint = pdfView.convert(point, to: page)
            
            if let selection = page.selectionForWord(at: pagePoint),
               let selectedText = selection.string?.trimmingCharacters(in: .whitespacesAndNewlines),
               !selectedText.isEmpty {
                parent.onWordSelected(selectedText)
            }
        }
    }
}

// MARK: - Translation UI Components
struct TranslationOverlayView: View {
    let translationResult: TranslationResult
    let isTranslating: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            VStack {
                Spacer()
                
                TranslationPopupView(
                    translationResult: translationResult,
                    isTranslating: isTranslating,
                    onDismiss: onDismiss
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .zIndex(1)
    }
}


// Add the Copy button to the ActionButtons row in TranslationPopupView
struct TranslationPopupView: View {
    let translationResult: TranslationResult
    let isTranslating: Bool
    let onDismiss: () -> Void
    @State private var isPlayingAudio = false
    @State private var audioURL: String?
    @State private var showChatSheet = false
    @State private var showCopiedFeedback = false  // For copy feedback
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            // Header with close button
            HStack {
                Text(translationResult.originalText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Translation content
            HStack {
                Spacer()
                
                if isTranslating {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(translationResult.translatedText)
                            .font(.headline)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                        
                        Text("Arabic Translation")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 20) {
                AudioButton(
                    text: translationResult.originalText,
                    language: translationResult.targetLanguage,
                    isPlaying: $isPlayingAudio,
                    audioURL: $audioURL
                )
                
                // Lixe Bot button
                ActionButton(icon: "newspaper", title: "Simplify") {
                    
                    showChatSheet = true
                }

                ActionButton(icon: "doc.text.magnifyingglass", title: "Define") {
                   
                    showChatSheet = true
                }
                
                // Copy button
                Button {
                    // Copy the original text to clipboard
                    UIPasteboard.general.string = translationResult.translatedText
                    
                    // Show feedback
                    withAnimation {
                        showCopiedFeedback = true
                    }
                    
                    // Hide feedback after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCopiedFeedback = false
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: showCopiedFeedback ? "checkmark" : "wallet.pass")
                            .font(.system(size: 20))
                            .foregroundColor(showCopiedFeedback ? .green : .primary900)
                        
                        Text(showCopiedFeedback ? "Copied!" : "Copy")
                            .font(.caption2)
                            .foregroundColor(showCopiedFeedback ? .green : .primary900)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .sheet(isPresented: $showChatSheet) {
            NavigationView {
                ChatScreen(initialText: "Explain the Following \"\(translationResult.originalText)\"?")
            }
        }
    }
}

// Create a specific action button for the chatbot
struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primary900)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.primary900)
            }
        }
    }
}

// Create a dedicated audio button component
struct AudioButton: View {
    let text: String
    let language: String
    @Binding var isPlaying: Bool
    @Binding var audioURL: String?
    @State private var isLoading = false
    
    var body: some View {
        Button(action: {
            playAudio()
        }) {
            VStack(spacing: 4) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2")
                        .font(.system(size: 20))
                        .foregroundColor(.primary900)
                }
                
                Text("Speak")
                    .font(.caption2)
                    .foregroundColor(.primary900)
            }
        }
        .disabled(isLoading || isPlaying)
    }
    
    private func playAudio() {
        // If we already have an audio URL, play it
        if let existingURL = audioURL {
            isPlaying = true
            
            TranslationService.shared.playAudio(from: existingURL) {
                DispatchQueue.main.async {
                    self.isPlaying = false
                }
            }
            return
        }
        
        // Otherwise request a new audio URL
        isLoading = true
        
        TranslationService.shared.textToSpeech(text: text, language: language)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Audio error: \(error)")
                    }
                },
                receiveValue: { url in
                    audioURL = url
                    isPlaying = true
                    
                    TranslationService.shared.playAudio(from: url) {
                        DispatchQueue.main.async {
                            self.isPlaying = false
                        }
                    }
                }
            )
            .store(in: &TranslationService.shared.cancellables)
    }
}


// MARK: - Document Picker
struct DocumentPickerView: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let originalURL = urls.first else {
                print("No document selected")
                return
            }
            
            print("Document picked: \(originalURL.lastPathComponent)")
            
            // Start accessing the resource and keep it alive
            guard originalURL.startAccessingSecurityScopedResource() else {
                print("Failed to access security scoped resource")
                return
            }
            
            // Create a local copy immediately
            do {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent(originalURL.lastPathComponent)
                
                // Remove existing file with same name if any
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                // Copy the file
                try FileManager.default.copyItem(at: originalURL, to: destinationURL)
                
                // Stop accessing the original resource
                originalURL.stopAccessingSecurityScopedResource()
                
                // Verify the file was copied
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    print("File copied successfully to: \(destinationURL.path)")
                    
                    // Pass the file to the callback
                    DispatchQueue.main.async {
                        self.parent.onDocumentPicked(destinationURL)
                    }
                } else {
                    print("File not found after copying")
                }
            } catch {
                originalURL.stopAccessingSecurityScopedResource()
                print("Error copying file: \(error)")
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
        }
    }
}



extension UserDefaultKeys {
    static let savedPDFFiles = "savedPDFFiles"
    static let savedBooks = "savedBooks"           // ADD THIS
    static let downloadedBookPDFs = "downloadedBookPDFs"  // ADD THIS
}



extension PDFFile: Equatable {
    static func == (lhs: PDFFile, rhs: PDFFile) -> Bool {
        return lhs.id == rhs.id
    }
}
