//
//  PDFScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 05/03/2025.
//

import SwiftUI
import PDFKit
import Alamofire
import FileProvider

// MARK: - Models
struct PDFModel: Identifiable {
    let id = UUID()
    let url: URL?
    let fileName: String
    var extractedText: String = ""
    var pages: [PDFPage] = []
}

// MARK: - Services
class PDFService {
    static let shared = PDFService()
    
    func extractText(from pdfDocument: PDFDocument) -> String {
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            
            if let pageContent = page.string {
                extractedText += pageContent + "\n"
            }
        }
        
        return extractedText
    }
    
    func extractPages(from pdfDocument: PDFDocument) -> [PDFPage] {
        var pages: [PDFPage] = []
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            pages.append(page)
        }
        
        return pages
    }
}

// MARK: - Translation Service
class TranslationService {
    static let shared = TranslationService()
    
    func translateText(_ text: String,
                       sourceLanguage: String = "en",
                       targetLanguage: String = "ar",
                       completion: @escaping (String) -> Void) {
        // Simulated translation - replace with actual Alamofire API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(text)
        }
        
        // Example of how to implement with Alamofire:
        /*
         let parameters: [String: Any] = [
         "text": text,
         "source": sourceLanguage,
         "target": targetLanguage
         ]
         
         AF.request("https://translation-api-endpoint.com/translate",
         method: .post,
         parameters: parameters)
         .responseDecodable(of: TranslationResponse.self) { response in
         switch response.result {
         case .success(let translationResponse):
         completion(translationResponse.translatedText)
         case .failure(let error):
         print("Translation error: \(error)")
         completion(text) // Return original text on failure
         }
         }
         */
    }
}

// MARK: - View Model
class PDFViewModel: ObservableObject {
    @Published var pdfModel: PDFModel?
    @Published var selectedWord: String?
    @Published var translatedText: String?
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadLocalPDF(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") else {
            self.error = NSError(domain: "PDFLoadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "PDF file not found"])
            return
        }
        
        loadPDF(from: url)
    }
    
    func loadPDF(from url: URL) {
        isLoading = true
        
        // Check file existence
        guard FileManager.default.fileExists(atPath: url.path) else {
            self.error = NSError(domain: "PDFLoadError",
                                 code: 404,
                                 userInfo: [NSLocalizedDescriptionKey: "PDF file not found"])
            isLoading = false
            return
        }
        
        // Attempt to load PDF
        guard let pdfDocument = PDFDocument(url: url) else {
            self.error = NSError(domain: "PDFLoadError",
                                 code: 500,
                                 userInfo: [NSLocalizedDescriptionKey: "Could not load PDF document"])
            isLoading = false
            return
        }
        
        // Successful loading
        let extractedText = PDFService.shared.extractText(from: pdfDocument)
        let pages = PDFService.shared.extractPages(from: pdfDocument)
        
        self.pdfModel = PDFModel(
            url: url,
            fileName: url.lastPathComponent,
            extractedText: extractedText,
            pages: pages
        )
        
        isLoading = false
    }
    
    func translateWord(_ word: String) {
        guard !word.isEmpty else { return }
        
        isLoading = true
        TranslationService.shared.translateText(word) { [weak self] translation in
            DispatchQueue.main.async {
                self?.translatedText = translation
                self?.isLoading = false
            }
        }
    }
}

// MARK: - Main View
struct PDFReaderView: View {
    @StateObject private var viewModel = PDFViewModel()
    @State private var showTranslation = false
    @State private var selectedWord: String = ""
    @State private var pdfLoadError: String? = nil
    var pdfURL: URL?
    
    var body: some View {
        ZStack {
            if let error = pdfLoadError {
                VStack {
                    Text("Error loading PDF")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                PDFContentView(
                    viewModel: viewModel,
                    onWordSelected: { word in
                        selectedWord = word
                        viewModel.selectedWord = word
                        viewModel.translateWord(word)
                        showTranslation = true
                    }
                )
                
                // Translation Popup
                if showTranslation,
                   let word = viewModel.selectedWord,
                   let translation = viewModel.translatedText {
                    
                    TranslationOverlayView(
                        originalWord: word,
                        translation: translation,
                        onDismiss: {
                            showTranslation = false
                            viewModel.selectedWord = nil
                            viewModel.translatedText = nil
                        }
                    )
                }
            }
        }
        .onAppear {
            loadPDF()
        }
    }
    
    private func loadPDF() {
        if let url = pdfURL {
            print("Attempting to load PDF from: \(url.path)")
            
            // Check file exists
            if FileManager.default.fileExists(atPath: url.path) {
                let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
                print("PDF file exists, size: \(fileSize) bytes")
                
                viewModel.loadPDF(from: url)
                if let error = viewModel.error {
                    pdfLoadError = error.localizedDescription
                    print("Error loading PDF: \(error.localizedDescription)")
                }
            } else {
                pdfLoadError = "PDF file not found at path: \(url.path)"
                print("PDF file not found at: \(url.path)")
            }
        } else {
            print("No URL provided, loading sample PDF")
            viewModel.loadLocalPDF(named: "draft")
            if let error = viewModel.error {
                pdfLoadError = error.localizedDescription
                print("Error loading sample PDF: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - PDF Content View
struct PDFContentView: View {
    @ObservedObject var viewModel: PDFViewModel
    var onWordSelected: (String) -> Void
    
    var body: some View {
        VStack {
            if let pdfModel = viewModel.pdfModel {
                // PDF Content Display with Multi-page Support
                EnhancedPDFView(
                    pdfModel: pdfModel,
                    onWordSelected: onWordSelected
                )
            } else {
                ProgressView("Loading PDF...")
            }
        }
    }
}

// MARK: - Translation Overlay View
struct TranslationOverlayView: View {
    let originalWord: String
    let translation: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            TranslationPopupView(
                originalWord: originalWord,
                translation: translation,
                onDismiss: onDismiss
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))
        .zIndex(1)
    }
}

// MARK: - Enhanced PDF View with proper multi-page support and zooming
struct EnhancedPDFView: UIViewRepresentable {
    let pdfModel: PDFModel
    var onWordSelected: (String) -> Void
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Configure PDF View
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage      // You can change to .twoUp or other modes as needed
        pdfView.displayDirection = .vertical   // Vertical scrolling for pages
        pdfView.usePageViewController(true)    // Use page view controller for smooth page transitions
        
        // Enable zooming
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0
        pdfView.scaleFactor = 1.0              // Initial scale
        
        // Set up the document
        if let url = pdfModel.url {
            if let document = PDFDocument(url: url) {
                pdfView.document = document
                
                // Enable document link interaction (for internal links)
                pdfView.isUserInteractionEnabled = true
            }
        }
        
        // Double tap to select word
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        pdfView.addGestureRecognizer(doubleTapGesture)
        
        // Add a long press gesture for alternative text selection
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
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
            guard let pdfView = gesture.view as? PDFView else { return }
            let point = gesture.location(in: pdfView)
            
            // Get the tapped page
            guard let page = pdfView.page(for: point, nearest: true) else { return }
            
            // Convert point to page coordinates
            let pagePoint = pdfView.convert(point, to: page)
            
            // Get word at that location
            if let selection = page.selectionForWord(at: pagePoint) {
                if let selectedText = selection.string, !selectedText.isEmpty {
                    // Call the closure with the selected word
                    parent.onWordSelected(selectedText)
                }
            }
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                guard let pdfView = gesture.view as? PDFView else { return }
                let point = gesture.location(in: pdfView)
                
                // Get the page
                guard let page = pdfView.page(for: point, nearest: true) else { return }
                
                // Convert point to page coordinates
                let pagePoint = pdfView.convert(point, to: page)
                
                // Get word at that location
                if let selection = page.selectionForWord(at: pagePoint) {
                    if let selectedText = selection.string, !selectedText.isEmpty {
                        // Call the closure with the selected word
                        parent.onWordSelected(selectedText)
                    }
                }
            }
        }
    }
}

// MARK: - Translation Popup View
struct TranslationPopupView: View {
    let originalWord: String
    let translation: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Top section - Title
            HStack {
                Text("\(originalWord)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.darkText))
                
                Spacer()
                
                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundColor(Color(UIColor.darkText))
                }
            }
            .padding(.bottom, 4)
            
            // Center section - Arabic translation with right-to-left alignment
            HStack {
                Spacer()
                Text(translation)
                    .font(.headline)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color(UIColor.darkText))
            }
            
            // Original text explanation (RTL style)
            HStack {
                Spacer()
                Text("\(translation)")
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Color(UIColor.darkText))
            }
            
            // Bottom section - Controls
            PopupControlsView(onDismiss: onDismiss)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40)
        .background(Color(red: 0.8, green: 0.8, blue: 1.0))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Popup Controls View
struct PopupControlsView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        HStack {
            // Audio button
            PopupActionButton(icon: "volume") {
                // Audio playback action
            }
            
            
            
            // Dictionary button
            
            PopupActionButton(icon: "chatbot") {
            }
            
            
            
            
            // Plus/Add button
            PopupActionButton(icon: "add") {
                // Add to favorites or similar
            }
            
            
        }
        .padding(.top, 8)
        
    }
}

// MARK: - Popup Action Button
struct PopupActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(icon)
                .font(.system(size: 30))
                .foregroundColor(Color(UIColor.darkText))
            
        }
    }
}

#Preview {
    PDFReaderView()
}
