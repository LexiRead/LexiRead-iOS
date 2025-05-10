////
////  PdfViewModel .swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 05/03/2025.
////
//
//import SwiftUI
//import PDFKit
//import Alamofire
//import Combine
//import FileProvider
//
//struct PDFModel: Identifiable {
//    let id = UUID()
//    let url: URL?
//    let fileName: String
//    var extractedText: String = ""
//    var pages: [PDFPage] = []
//}
//
//
//class PDFService {
//    static let shared = PDFService()
//    
//    func extractText(from pdfDocument: PDFDocument) -> String {
//        var extractedText = ""
//        
//        for pageIndex in 0..<pdfDocument.pageCount {
//            guard let page = pdfDocument.page(at: pageIndex) else { continue }
//            
//            if let pageContent = page.string {
//                extractedText += pageContent + "\n"
//            }
//        }
//        
//        return extractedText
//    }
//    
//    func extractPages(from pdfDocument: PDFDocument) -> [PDFPage] {
//        var pages: [PDFPage] = []
//        
//        for pageIndex in 0..<pdfDocument.pageCount {
//            guard let page = pdfDocument.page(at: pageIndex) else { continue }
//            pages.append(page)
//        }
//        
//        return pages
//    }
//}
//
//// MARK: - Translation Service
//class TranslationService {
//    static let shared = TranslationService()
//    
//    func translateText(_ text: String,
//                       sourceLanguage: String = "en",
//                       targetLanguage: String = "ar") -> AnyPublisher<String, Never> {
//        // Simulated translation - replace with actual API call
//        return Just("Translation for: \(text)")
//            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//}
//
//
//class PDFViewModel: ObservableObject {
//    @Published var pdfModel: PDFModel?
//    @Published var selectedWord: String?
//    @Published var translatedText: String?
//    @Published var isLoading = false
//    @Published var error: Error?
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func loadLocalPDF(named fileName: String) {
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") else {
//            self.error = NSError(domain: "PDFLoadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "PDF file not found"])
//            return
//        }
//        
//        loadPDF(from: url)
//    }
//    
//    func loadPDF(from url: URL) {
//        isLoading = true
//        
//        // Check file existence
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            self.error = NSError(domain: "PDFLoadError",
//                                 code: 404,
//                                 userInfo: [NSLocalizedDescriptionKey: "PDF file not found"])
//            isLoading = false
//            return
//        }
//        
//        // Attempt to load PDF
//        guard let pdfDocument = PDFDocument(url: url) else {
//            self.error = NSError(domain: "PDFLoadError",
//                                 code: 500,
//                                 userInfo: [NSLocalizedDescriptionKey: "Could not load PDF document"])
//            isLoading = false
//            return
//        }
//        
//        // Successful loading
//        let extractedText = PDFService.shared.extractText(from: pdfDocument)
//        let pages = PDFService.shared.extractPages(from: pdfDocument)
//        
//        self.pdfModel = PDFModel(
//            url: url,
//            fileName: url.lastPathComponent,
//            extractedText: extractedText,
//            pages: pages
//        )
//        
//        isLoading = false
//    }
//    
//    func translateWord(_ word: String) {
//        guard !word.isEmpty else { return }
//        
//        isLoading = true
//        TranslationService.shared.translateText(word)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] translation in
//                self?.translatedText = translation
//                self?.isLoading = false
//            }
//            .store(in: &cancellables)
//    }
//}









//
//  HTMLToPDFConverter.swift
//  LexiRead
//
//  Created on 09/05/2025.
//

import Foundation
import WebKit
import PDFKit
import UIKit

class HTMLToPDFConverter: NSObject, WKNavigationDelegate {
    // Singleton instance
    static let shared = HTMLToPDFConverter()
    
    // Web view for rendering HTML
    private var webView: WKWebView?
    
    // Completion handler
    private var completion: ((URL?) -> Void)?
    
    // Output PDF URL
    private var outputURL: URL?
    
    // Private initializer for singleton
    private override init() {
        super.init()
    }
    
    // Convert HTML URL to PDF
    func convertHTMLToPDF(url htmlURL: URL, outputFileName: String, completion: @escaping (URL?) -> Void) {
        print("Starting HTML to PDF conversion for: \(htmlURL)")
        
        // Store completion handler
        self.completion = completion
        
        // Create output URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.outputURL = documentsDirectory.appendingPathComponent(outputFileName)
        
        // Remove any existing file
        if let outputURL = self.outputURL, FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        // Set up configuration
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        // Create web view offscreen
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1024, height: 1400), configuration: config)
        webView.navigationDelegate = self
        self.webView = webView
        
        // Load the URL
        print("Loading HTML content from: \(htmlURL)")
        webView.load(URLRequest(url: htmlURL))
    }
    
    // First try to extract PDF links from the HTML
    func loadHTMLAndCheckForPDFLinks(url htmlURL: URL, outputFileName: String, completion: @escaping (URL?) -> Void) {
        // Send a request to get the HTML content
        let task = URLSession.shared.dataTask(with: htmlURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Handle errors
            if let error = error {
                print("Error loading HTML: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Check if we got data
            guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                print("No data received or couldn't convert to string")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Search for direct PDF links
            if let pdfURLString = self.findPDFLinkInHTML(htmlString, baseURL: htmlURL) {
                print("Found direct PDF link: \(pdfURLString)")
                
                // Download the PDF directly
                if let pdfURL = URL(string: pdfURLString) {
                    self.downloadPDF(from: pdfURL, saveTo: outputFileName, completion: completion)
                    return
                }
            }
            
            // If no PDF link found, try other Gutenberg patterns
            if htmlURL.absoluteString.contains("gutenberg.org/ebooks/") {
                if let bookID = self.extractGutenbergID(from: htmlURL.absoluteString) {
                    // Try common Gutenberg PDF patterns
                    let possiblePDFURLs = [
                        "https://www.gutenberg.org/files/\(bookID)/\(bookID)-pdf.pdf",
                        "https://www.gutenberg.org/cache/epub/\(bookID)/pg\(bookID).pdf",
                        "https://www.gutenberg.org/ebooks/\(bookID).pdf"
                    ]
                    
                    for urlString in possiblePDFURLs {
                        print("Trying Gutenberg pattern: \(urlString)")
                        if let url = URL(string: urlString) {
                            // Try to download each potential PDF URL
                            self.testPDFURL(url) { exists in
                                if exists {
                                    print("Found working PDF URL: \(urlString)")
                                    self.downloadPDF(from: url, saveTo: outputFileName, completion: completion)
                                    return
                                }
                            }
                        }
                    }
                }
            }
            
            // If no direct PDF link found, convert HTML to PDF
            print("No direct PDF link found, converting HTML to PDF")
            DispatchQueue.main.async {
                self.convertHTMLToPDF(url: htmlURL, outputFileName: outputFileName, completion: completion)
            }
        }
        
        task.resume()
    }
    
    // Extract Gutenberg book ID from URL
    private func extractGutenbergID(from urlString: String) -> String? {
        if let range = urlString.range(of: "/ebooks/") {
            let afterEbooks = urlString[range.upperBound...]
            if let endRange = afterEbooks.firstIndex(where: { !$0.isNumber }) {
                return String(afterEbooks[..<endRange])
            } else {
                return String(afterEbooks)
            }
        }
        return nil
    }
    
    // Find PDF links in HTML content
    private func findPDFLinkInHTML(_ html: String, baseURL: URL) -> String? {
        // Patterns to search for PDF links
        let patterns = [
            "href=\"([^\"]+\\.pdf)\"",
            "href='([^']+\\.pdf)'",
            "<a[^>]+href=\"([^\"]+\\.pdf)\"[^>]*>",
            "src=\"([^\"]+\\.pdf)\""
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = html as NSString
                let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let urlString = nsString.substring(with: match.range(at: 1))
                        
                        // Handle relative URLs
                        if urlString.hasPrefix("/") || !urlString.contains("://") {
                            return URL(string: urlString, relativeTo: baseURL)?.absoluteString
                        } else {
                            return urlString
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    // Test if a PDF URL exists
    private func testPDFURL(_ url: URL, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }
    
    // Download PDF directly
    private func downloadPDF(from url: URL, saveTo filename: String, completion: @escaping (URL?) -> Void) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent(filename)
        
        // Remove existing file if any
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                print("Error downloading PDF: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let tempURL = tempURL else {
                print("No temporary URL provided")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                // Move to permanent location
                try FileManager.default.copyItem(at: tempURL, to: outputURL)
                print("PDF downloaded to: \(outputURL.path)")
                
                // Verify it's a valid PDF
                if let _ = PDFDocument(url: outputURL) {
                    DispatchQueue.main.async {
                        completion(outputURL)
                    }
                } else {
                    print("Downloaded file is not a valid PDF")
                    try? FileManager.default.removeItem(at: outputURL)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Error saving PDF: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    // WKNavigationDelegate method - called when page finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web view finished loading HTML, beginning conversion to PDF")
        
        // Wait a bit to ensure all content is rendered
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.createPDFFromWebView(webView)
        }
    }
    
    // Create PDF from the loaded web view
    private func createPDFFromWebView(_ webView: WKWebView) {
        // Ensure we have the output URL
        guard let outputURL = self.outputURL else {
            print("No output URL specified")
            self.completion?(nil)
            return
        }
        
        // Get printable size
        let pageSize = CGSize(width: 612, height: 792) // US Letter size in points
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        do {
            // Create PDF file
            try renderer.writePDF(to: outputURL) { context in
                context.beginPage()
                
                // Create a snapshot of the web view
                let bounds = webView.bounds
                UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
                webView.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // Draw the image to the PDF
                if let image = image {
                    image.draw(in: CGRect(origin: .zero, size: pageSize))
                }
            }
            
            print("PDF created successfully at: \(outputURL.path)")
            
            // Verify the PDF is valid
            if let pdfDocument = PDFDocument(url: outputURL), pdfDocument.pageCount > 0 {
                print("Generated valid PDF with \(pdfDocument.pageCount) pages")
                self.completion?(outputURL)
            } else {
                print("Generated PDF is invalid")
                try? FileManager.default.removeItem(at: outputURL)
                self.completion?(nil)
            }
        } catch {
            print("Error creating PDF: \(error.localizedDescription)")
            self.completion?(nil)
        }
        
        // Clean up
        self.webView = nil
        self.completion = nil
    }
    
    // Web view navigation failed
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Web view navigation failed: \(error.localizedDescription)")
        self.completion?(nil)
        
        // Clean up
        self.webView = nil
        self.completion = nil
    }
}

// Extension to BooksViewModel to use the HTML to PDF converter
extension BooksViewModel {
    // Direct conversion from HTML to PDF for book links
    func convertAndOpenBookPDF(for book: Book, completion: @escaping (URL?) -> Void) {
        print("Starting HTML to PDF conversion for book: \(book.title)")
        
        // Create a sanitized filename
        let sanitizedTitle = book.title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "_")
        let filename = "book_\(book.id)_\(sanitizedTitle).pdf"
        
        // Check if we already have a converted PDF
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: localURL.path)[.size] as? Int64) ?? 0
            print("Found existing PDF at: \(localURL.path), size: \(fileSize) bytes")
            
            if fileSize > 1000, let _ = PDFDocument(url: localURL) {
                print("Using existing valid PDF")
                completion(localURL)
                return
            } else {
                try? FileManager.default.removeItem(at: localURL)
                print("Removed invalid existing PDF")
            }
        }
        
        // Check for download links
        guard let downloadLinks = book.downloadLinks else {
            print("No download links available for book: \(book.title)")
            self.useFallbackPDF(completion: completion)
            return
        }
        
        // Try PDF link first
        if let pdfURLString = downloadLinks.pdf, !pdfURLString.isEmpty,
           let pdfURL = URL(string: pdfURLString) {
            print("Using direct PDF link: \(pdfURLString)")
            self.downloadDirectPDF(from: pdfURL, filename: filename, completion: completion)
            return
        }
        
        // Use HTML link and convert
        if let htmlURLString = downloadLinks.text_html, !htmlURLString.isEmpty,
           let htmlURL = URL(string: htmlURLString) {
            print("Using HTML link for conversion: \(htmlURLString)")
            
            // First check for direct PDF links in the HTML
            HTMLToPDFConverter.shared.loadHTMLAndCheckForPDFLinks(
                url: htmlURL,
                outputFileName: filename,
                completion: { [weak self] url in
                    guard let self = self else { return }
                    
                    if let url = url {
                        completion(url)
                    } else {
                        print("HTML to PDF conversion failed, using fallback")
                        self.useFallbackPDF(completion: completion)
                    }
                }
            )
            return
        }
        
        // If no usable links, use fallback
        print("No usable links found for book: \(book.title)")
        self.useFallbackPDF(completion: completion)
    }
    
    // Download PDF directly
    private func downloadDirectPDF(from url: URL, filename: String, completion: @escaping (URL?) -> Void) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(filename)
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                print("Error downloading PDF: \(error.localizedDescription)")
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
                
                // Verify the PDF
                if let pdfDocument = PDFDocument(url: localURL), pdfDocument.pageCount > 0 {
                    print("Downloaded valid PDF: \(localURL.path)")
                    DispatchQueue.main.async {
                        completion(localURL)
                    }
                } else {
                    print("Downloaded PDF is invalid")
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
        }
        
        task.resume()
    }
    
    // Use fallback sample PDF
    private func useFallbackPDF(completion: @escaping (URL?) -> Void) {
        if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
            print("Using sample PDF fallback")
            completion(sampleURL)
        } else {
            print("Sample PDF not found")
            completion(nil)
        }
    }
}


