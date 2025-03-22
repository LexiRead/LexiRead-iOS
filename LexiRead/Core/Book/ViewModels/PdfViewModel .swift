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
