////
////  PDFScreen.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 05/03/2025.
////
//
//import SwiftUI
//import PDFKit
//import Alamofire
//import FileProvider
//
//// MARK: - Models
//struct PDFModel: Identifiable {
//    let id = UUID()
//    let url: URL?
//    let fileName: String
//    var extractedText: String = ""
//    var pages: [PDFPage] = []
//}
//
//// MARK: - Services
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
//                       targetLanguage: String = "ar",
//                       completion: @escaping (String) -> Void) {
//        // Simulated translation - replace with actual Alamofire API call
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            completion(text)
//        }
//        
//        // Example of how to implement with Alamofire:
//        /*
//         let parameters: [String: Any] = [
//         "text": text,
//         "source": sourceLanguage,
//         "target": targetLanguage
//         ]
//         
//         AF.request("https://translation-api-endpoint.com/translate",
//         method: .post,
//         parameters: parameters)
//         .responseDecodable(of: TranslationResponse.self) { response in
//         switch response.result {
//         case .success(let translationResponse):
//         completion(translationResponse.translatedText)
//         case .failure(let error):
//         print("Translation error: \(error)")
//         completion(text) // Return original text on failure
//         }
//         }
//         */
//    }
//}
//
//// MARK: - View Model
//class PDFViewModel: ObservableObject {
//    @Published var pdfModel: PDFModel?
//    @Published var selectedWord: String?
//    @Published var translatedText: String?
//    @Published var isLoading = false
//    @Published var error: Error?
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
//        TranslationService.shared.translateText(word) { [weak self] translation in
//            DispatchQueue.main.async {
//                self?.translatedText = translation
//                self?.isLoading = false
//            }
//        }
//    }
//}
//
//// MARK: - Main View
//struct PDFReaderView: View {
//    @StateObject private var viewModel = PDFViewModel()
//    @State private var showTranslation = false
//    @State private var selectedWord: String = ""
//    @State private var pdfLoadError: String? = nil
//    var pdfURL: URL?
//    
//    var body: some View {
//        ZStack {
//            if let error = pdfLoadError {
//                VStack {
//                    Text("Error loading PDF")
//                        .font(.headline)
//                        .foregroundColor(.red)
//                        .padding()
//                    
//                    Text(error)
//                        .font(.subheadline)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//            } else {
//                PDFContentView(
//                    viewModel: viewModel,
//                    onWordSelected: { word in
//                        selectedWord = word
//                        viewModel.selectedWord = word
//                        viewModel.translateWord(word)
//                        showTranslation = true
//                    }
//                )
//                
//                // Translation Popup
//                if showTranslation,
//                   let word = viewModel.selectedWord,
//                   let translation = viewModel.translatedText {
//                    
//                    TranslationOverlayView(
//                        originalWord: word,
//                        translation: translation,
//                        onDismiss: {
//                            showTranslation = false
//                            viewModel.selectedWord = nil
//                            viewModel.translatedText = nil
//                        }
//                    )
//                }
//            }
//        }
//        .onAppear {
//            loadPDF()
//        }
//    }
//    
//    private func loadPDF() {
//        if let url = pdfURL {
//            print("Attempting to load PDF from: \(url.path)")
//            
//            // Check file exists
//            if FileManager.default.fileExists(atPath: url.path) {
//                let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
//                print("PDF file exists, size: \(fileSize) bytes")
//                
//                viewModel.loadPDF(from: url)
//                if let error = viewModel.error {
//                    pdfLoadError = error.localizedDescription
//                    print("Error loading PDF: \(error.localizedDescription)")
//                }
//            } else {
//                pdfLoadError = "PDF file not found at path: \(url.path)"
//                print("PDF file not found at: \(url.path)")
//            }
//        } else {
//            print("No URL provided, loading sample PDF")
//            viewModel.loadLocalPDF(named: "draft")
//            if let error = viewModel.error {
//                pdfLoadError = error.localizedDescription
//                print("Error loading sample PDF: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//// MARK: - PDF Content View
//struct PDFContentView: View {
//    @ObservedObject var viewModel: PDFViewModel
//    var onWordSelected: (String) -> Void
//    
//    var body: some View {
//        VStack {
//            if let pdfModel = viewModel.pdfModel {
//                // PDF Content Display with Multi-page Support
//                EnhancedPDFView(
//                    pdfModel: pdfModel,
//                    onWordSelected: onWordSelected
//                )
//            } else {
//                ProgressView("Loading PDF...")
//            }
//        }
//    }
//}
//
//// MARK: - Translation Overlay View
//struct TranslationOverlayView: View {
//    let originalWord: String
//    let translation: String
//    var onDismiss: () -> Void
//    
//    var body: some View {
//        VStack {
//            TranslationPopupView(
//                originalWord: originalWord,
//                translation: translation,
//                onDismiss: onDismiss
//            )
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//        .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))
//        .zIndex(1)
//    }
//}
//
//// MARK: - Enhanced PDF View with proper multi-page support and zooming
//struct EnhancedPDFView: UIViewRepresentable {
//    let pdfModel: PDFModel
//    var onWordSelected: (String) -> Void
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        
//        // Configure PDF View
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePage      // You can change to .twoUp or other modes as needed
//        pdfView.displayDirection = .vertical   // Vertical scrolling for pages
//        pdfView.usePageViewController(true)    // Use page view controller for smooth page transitions
//        
//        // Enable zooming
//        pdfView.minScaleFactor = 0.5
//        pdfView.maxScaleFactor = 5.0
//        pdfView.scaleFactor = 1.0              // Initial scale
//        
//        // Set up the document
//        if let url = pdfModel.url {
//            if let document = PDFDocument(url: url) {
//                pdfView.document = document
//                
//                // Enable document link interaction (for internal links)
//                pdfView.isUserInteractionEnabled = true
//            }
//        }
//        
//        // Double tap to select word
//        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
//        doubleTapGesture.numberOfTapsRequired = 2
//        pdfView.addGestureRecognizer(doubleTapGesture)
//        
//        // Add a long press gesture for alternative text selection
//        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
//        longPressGesture.minimumPressDuration = 0.5
//        pdfView.addGestureRecognizer(longPressGesture)
//        
//        return pdfView
//    }
//    
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        // Update if needed
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject {
//        var parent: EnhancedPDFView
//        
//        init(_ parent: EnhancedPDFView) {
//            self.parent = parent
//        }
//        
//        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//            guard let pdfView = gesture.view as? PDFView else { return }
//            let point = gesture.location(in: pdfView)
//            
//            // Get the tapped page
//            guard let page = pdfView.page(for: point, nearest: true) else { return }
//            
//            // Convert point to page coordinates
//            let pagePoint = pdfView.convert(point, to: page)
//            
//            // Get word at that location
//            if let selection = page.selectionForWord(at: pagePoint) {
//                if let selectedText = selection.string, !selectedText.isEmpty {
//                    // Call the closure with the selected word
//                    parent.onWordSelected(selectedText)
//                }
//            }
//        }
//        
//        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//            if gesture.state == .began {
//                guard let pdfView = gesture.view as? PDFView else { return }
//                let point = gesture.location(in: pdfView)
//                
//                // Get the page
//                guard let page = pdfView.page(for: point, nearest: true) else { return }
//                
//                // Convert point to page coordinates
//                let pagePoint = pdfView.convert(point, to: page)
//                
//                // Get word at that location
//                if let selection = page.selectionForWord(at: pagePoint) {
//                    if let selectedText = selection.string, !selectedText.isEmpty {
//                        // Call the closure with the selected word
//                        parent.onWordSelected(selectedText)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Translation Popup View
//struct TranslationPopupView: View {
//    let originalWord: String
//    let translation: String
//    var onDismiss: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 8) {
//            // Top section - Title
//            HStack {
//                Text("\(originalWord)")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color(UIColor.darkText))
//                
//                Spacer()
//                
//                // Dismiss button
//                Button {
//                    onDismiss()
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 22))
//                        .foregroundColor(Color(UIColor.darkText))
//                }
//            }
//            .padding(.bottom, 4)
//            
//            // Center section - Arabic translation with right-to-left alignment
//            HStack {
//                Spacer()
//                Text(translation)
//                    .font(.headline)
//                    .multilineTextAlignment(.trailing)
//                    .foregroundColor(Color(UIColor.darkText))
//            }
//            
//            // Original text explanation (RTL style)
//            HStack {
//                Spacer()
//                Text("\(translation)")
//                    .font(.subheadline)
//                    .multilineTextAlignment(.trailing)
//                    .foregroundColor(Color(UIColor.darkText))
//            }
//            
//            // Bottom section - Controls
//            PopupControlsView(onDismiss: onDismiss)
//        }
//        .padding()
//        .frame(width: UIScreen.main.bounds.width - 40)
//        .background(Color(red: 0.8, green: 0.8, blue: 1.0))
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
//    }
//}
//
//// MARK: - Popup Controls View
//struct PopupControlsView: View {
//    var onDismiss: () -> Void
//    
//    var body: some View {
//        HStack {
//            // Audio button
//            PopupActionButton(icon: "volume") {
//                // Audio playback action
//            }
//            
//            
//            
//            // Dictionary button
//            
//            PopupActionButton(icon: "chatbot") {
//            }
//            
//            
//            
//            
//            // Plus/Add button
//            PopupActionButton(icon: "add") {
//                // Add to favorites or similar
//            }
//            
//            
//        }
//        .padding(.top, 8)
//        
//    }
//}
//
//// MARK: - Popup Action Button
//struct PopupActionButton: View {
//    let icon: String
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Image(icon)
//                .font(.system(size: 30))
//                .foregroundColor(Color(UIColor.darkText))
//            
//        }
//    }
//}
//
//#Preview {
//    PDFReaderView()
//}


////
////  PDFReaderView.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 05/03/2025.
////
//
//import SwiftUI
//import PDFKit
//import Combine
//
//// MARK: - Models
//struct PDFModel: Identifiable {
//    let id = UUID()
//    let url: URL?
//    let fileName: String
//    var extractedText: String = ""
//    var pageCount: Int = 0
//}
//
//struct TranslationResult {
//    let originalText: String
//    let translatedText: String
//    let sourceLanguage: String
//    let targetLanguage: String
//}
//
//// MARK: - Services
//class PDFService {
//    static let shared = PDFService()
//    
//    private init() {}
//    
//    func loadPDF(from url: URL) -> AnyPublisher<PDFModel, APIError> {
//        return Future { promise in
//            DispatchQueue.global(qos: .background).async {
//                guard FileManager.default.fileExists(atPath: url.path) else {
//                    DispatchQueue.main.async {
//                        promise(.failure(APIError.invalidURL))
//                    }
//                    return
//                }
//                
//                guard let pdfDocument = PDFDocument(url: url) else {
//                    DispatchQueue.main.async {
//                        promise(.failure(APIError.invalidData))
//                    }
//                    return
//                }
//                
//                let extractedText = self.extractText(from: pdfDocument)
//                let model = PDFModel(
//                    url: url,
//                    fileName: url.lastPathComponent,
//                    extractedText: extractedText,
//                    pageCount: pdfDocument.pageCount
//                )
//                
//                DispatchQueue.main.async {
//                    promise(.success(model))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    func downloadBookPDF(for book: Book) -> AnyPublisher<URL, APIError> {
//        return Future { promise in
//            let sanitizedTitle = book.title.replacingOccurrences(of: " ", with: "_")
//                                          .replacingOccurrences(of: "/", with: "-")
//                                          .replacingOccurrences(of: ":", with: "_")
//            let filename = "book_\(book.id)_\(sanitizedTitle).pdf"
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let destinationURL = documentsDirectory.appendingPathComponent(filename)
//            
//            // Check if already downloaded
//            if FileManager.default.fileExists(atPath: destinationURL.path) {
//                let fileSize = (try? FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64) ?? 0
//                if fileSize > 1000 {
//                    DispatchQueue.main.async {
//                        promise(.success(destinationURL))
//                    }
//                    return
//                }
//            }
//            
//            // Try to download from available links
//            if let pdfURL = book.downloadLinks?.pdf,
//               let url = URL(string: pdfURL) {
//                self.downloadFile(from: url, to: destinationURL) { success in
//                    if success {
//                        promise(.success(destinationURL))
//                    } else {
//                        self.useFallbackPDF(promise: promise)
//                    }
//                }
//            } else {
//                self.useFallbackPDF(promise: promise)
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    private func extractText(from pdfDocument: PDFDocument) -> String {
//        var extractedText = ""
//        
//        for pageIndex in 0..<pdfDocument.pageCount {
//            guard let page = pdfDocument.page(at: pageIndex) else { continue }
//            if let pageContent = page.string {
//                extractedText += pageContent + "\n"
//            }
//        }
//        
//        return extractedText
//    }
//    
//    private func downloadFile(from url: URL, to destinationURL: URL, completion: @escaping (Bool) -> Void) {
//        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
//            guard let tempURL = tempURL, error == nil else {
//                DispatchQueue.main.async { completion(false) }
//                return
//            }
//            
//            do {
//                if FileManager.default.fileExists(atPath: destinationURL.path) {
//                    try FileManager.default.removeItem(at: destinationURL)
//                }
//                
//                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
//                
//                // Verify it's a valid PDF
//                if let pdfDocument = PDFDocument(url: destinationURL), pdfDocument.pageCount > 0 {
//                    DispatchQueue.main.async { completion(true) }
//                } else {
//                    try? FileManager.default.removeItem(at: destinationURL)
//                    DispatchQueue.main.async { completion(false) }
//                }
//            } catch {
//                DispatchQueue.main.async { completion(false) }
//            }
//        }.resume()
//    }
//    
//    private func useFallbackPDF(promise: @escaping (Result<URL, APIError>) -> Void) {
//        if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
//            DispatchQueue.main.async {
//                promise(.success(sampleURL))
//            }
//        } else {
//            DispatchQueue.main.async {
//                promise(.failure(APIError.invalidData))
//            }
//        }
//    }
//}
//
//class TranslationService {
//    static let shared = TranslationService()
//    
//    private init() {}
//    
//    func translateText(_ text: String,
//                      sourceLanguage: String = "en",
//                      targetLanguage: String = "ar") -> AnyPublisher<TranslationResult, APIError> {
//        return Future { promise in
//            // Simulate API call with delay
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                // Mock translation - replace with actual API implementation
//                let result = TranslationResult(
//                    originalText: text,
//                    translatedText: "ترجمة: \(text)", // Mock Arabic translation
//                    sourceLanguage: sourceLanguage,
//                    targetLanguage: targetLanguage
//                )
//                promise(.success(result))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    // TODO: Implement actual translation API using Alamofire
//    /*
//    func translateText(_ text: String,
//                      sourceLanguage: String = "en",
//                      targetLanguage: String = "ar") -> AnyPublisher<TranslationResult, APIError> {
//        let parameters: [String: Any] = [
//            "text": text,
//            "source": sourceLanguage,
//            "target": targetLanguage
//        ]
//        
//        return NetworkManager.shared.post(
//            endpoint: "translate",
//            parameters: parameters,
//            requiresAuth: false
//        )
//    }
//    */
//}
//
//// MARK: - ViewModels
//class PDFReaderViewModel: ObservableObject {
//    @Published var pdfModel: PDFModel?
//    @Published var selectedWord: String?
//    @Published var translationResult: TranslationResult?
//    @Published var isLoading = false
//    @Published var isTranslating = false
//    @Published var errorMessage: String?
//    @Published var showTranslation = false
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func loadPDF(from url: URL) {
//        isLoading = true
//        errorMessage = nil
//        
//        PDFService.shared.loadPDF(from: url)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] pdfModel in
//                    self?.pdfModel = pdfModel
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func loadBookPDF(for book: Book) {
//        isLoading = true
//        errorMessage = nil
//        
//        PDFService.shared.downloadBookPDF(for: book)
//            .flatMap { url in
//                PDFService.shared.loadPDF(from: url)
//            }
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] pdfModel in
//                    self?.pdfModel = pdfModel
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func translateWord(_ word: String) {
//        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        
//        selectedWord = word
//        isTranslating = true
//        
//        TranslationService.shared.translateText(word)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isTranslating = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] result in
//                    self?.translationResult = result
//                    self?.showTranslation = true
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func dismissTranslation() {
//        showTranslation = false
//        selectedWord = nil
//        translationResult = nil
//    }
//}
//
//// MARK: - Main Views
//struct PDFReaderView: View {
//    @StateObject private var viewModel = PDFReaderViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    
//    let book: Book?
//    let pdfFile: PDFFile?
//    
//    init(book: Book) {
//        self.book = book
//        self.pdfFile = nil
//    }
//    
//    init(pdfFile: PDFFile) {
//        self.book = nil
//        self.pdfFile = pdfFile
//    }
//    
//    var body: some View {
//        ZStack {
//            if viewModel.isLoading {
//                LoadingView()
//            } else if let errorMessage = viewModel.errorMessage {
//                ErrorView(message: errorMessage) {
//                    loadContent()
//                }
//            } else if let pdfModel = viewModel.pdfModel {
//                PDFContentView(
//                    pdfModel: pdfModel,
//                    onWordSelected: { word in
//                        viewModel.translateWord(word)
//                    }
//                )
//            } else {
//                EmptyPDFView {
//                    loadContent()
//                }
//            }
//            
//            // Translation Overlay
//            if viewModel.showTranslation,
//               let result = viewModel.translationResult {
//                TranslationOverlayView(
//                    translationResult: result,
//                    isTranslating: viewModel.isTranslating,
//                    onDismiss: {
//                        viewModel.dismissTranslation()
//                    }
//                )
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(false)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Done") {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//        }
//        .onAppear {
//            loadContent()
//        }
//    }
//    
//    private func loadContent() {
//        if let book = book {
//            viewModel.loadBookPDF(for: book)
//        } else if let pdfFile = pdfFile {
//            let url = getURLForPDFFile(pdfFile)
//            if let validURL = url {
//                viewModel.loadPDF(from: validURL)
//            } else {
//                viewModel.errorMessage = "Could not locate PDF file"
//            }
//        }
//    }
//    
//    private func getURLForPDFFile(_ pdfFile: PDFFile) -> URL? {
//        if pdfFile.fileURL.starts(with: "/") {
//            return URL(fileURLWithPath: pdfFile.fileURL)
//        }
//        
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let localURL = documentsDirectory.appendingPathComponent(pdfFile.filename)
//        
//        if FileManager.default.fileExists(atPath: localURL.path) {
//            return localURL
//        }
//        
//        return nil
//    }
//}
//
//struct PDFContentView: View {
//    let pdfModel: PDFModel
//    let onWordSelected: (String) -> Void
//    
//    var body: some View {
//        VStack {
//            if let url = pdfModel.url {
//                EnhancedPDFView(
//                    pdfURL: url,
//                    onWordSelected: onWordSelected
//                )
//            } else {
//                Text("No PDF content available")
//                    .foregroundColor(.gray)
//                    .font(.headline)
//            }
//        }
//    }
//}
//
//struct EmptyPDFView: View {
//    let retryAction: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Image(systemName: "doc.text")
//                .font(.system(size: 50))
//                .foregroundColor(.gray)
//            
//            Text("No PDF Loaded")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            Text("Unable to load the PDF document")
//                .font(.body)
//                .foregroundColor(.gray)
//            
//            Button("Try Again") {
//                retryAction()
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .background(Color.primary900)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//        .padding()
//    }
//}
//
//// MARK: - PDF Viewer Component
//struct EnhancedPDFView: UIViewRepresentable {
//    let pdfURL: URL
//    let onWordSelected: (String) -> Void
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        
//        // Configure PDF View
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePage
//        pdfView.displayDirection = .vertical
//        pdfView.usePageViewController(true)
//        
//        // Enable zooming
//        pdfView.minScaleFactor = 0.5
//        pdfView.maxScaleFactor = 5.0
//        pdfView.scaleFactor = 1.0
//        
//        // Load document
//        if let document = PDFDocument(url: pdfURL) {
//            pdfView.document = document
//        }
//        
//        // Add gesture recognizers
//        let doubleTapGesture = UITapGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleDoubleTap(_:))
//        )
//        doubleTapGesture.numberOfTapsRequired = 2
//        pdfView.addGestureRecognizer(doubleTapGesture)
//        
//        let longPressGesture = UILongPressGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleLongPress(_:))
//        )
//        longPressGesture.minimumPressDuration = 0.5
//        pdfView.addGestureRecognizer(longPressGesture)
//        
//        return pdfView
//    }
//    
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        // Update if needed
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject {
//        var parent: EnhancedPDFView
//        
//        init(_ parent: EnhancedPDFView) {
//            self.parent = parent
//        }
//        
//        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//            extractWordAtGesture(gesture)
//        }
//        
//        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//            if gesture.state == .began {
//                extractWordAtGesture(gesture)
//            }
//        }
//        
//        private func extractWordAtGesture(_ gesture: UIGestureRecognizer) {
//            guard let pdfView = gesture.view as? PDFView else { return }
//            let point = gesture.location(in: pdfView)
//            
//            guard let page = pdfView.page(for: point, nearest: true) else { return }
//            let pagePoint = pdfView.convert(point, to: page)
//            
//            if let selection = page.selectionForWord(at: pagePoint),
//               let selectedText = selection.string?.trimmingCharacters(in: .whitespacesAndNewlines),
//               !selectedText.isEmpty {
//                parent.onWordSelected(selectedText)
//            }
//        }
//    }
//}
//
//// MARK: - Translation UI Components
//struct TranslationOverlayView: View {
//    let translationResult: TranslationResult
//    let isTranslating: Bool
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.3)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    onDismiss()
//                }
//            
//            VStack {
//                Spacer()
//                
//                TranslationPopupView(
//                    translationResult: translationResult,
//                    isTranslating: isTranslating,
//                    onDismiss: onDismiss
//                )
//                .padding(.horizontal, 20)
//                
//                Spacer()
//            }
//        }
//        .zIndex(1)
//    }
//}
//
//struct TranslationPopupView: View {
//    let translationResult: TranslationResult
//    let isTranslating: Bool
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 16) {
//            // Header with close button
//            HStack {
//                Text(translationResult.originalText)
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                    .lineLimit(2)
//                
//                Spacer()
//                
//                Button(action: onDismiss) {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Divider()
//            
//            // Translation content
//            HStack {
//                Spacer()
//                
//                if isTranslating {
//                    ProgressView()
//                        .scaleEffect(0.8)
//                } else {
//                    VStack(alignment: .trailing, spacing: 8) {
//                        Text(translationResult.translatedText)
//                            .font(.headline)
//                            .multilineTextAlignment(.trailing)
//                            .foregroundColor(.primary)
//                        
//                        Text("Arabic Translation")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            
//            // Action buttons
//            HStack(spacing: 20) {
//                ActionButton(icon: "speaker.wave.2", title: "Speak") {
//                    // TODO: Implement text-to-speech
//                }
//                
//                ActionButton(icon: "heart", title: "Save") {
//                    // TODO: Implement save to favorites
//                }
//                
//                ActionButton(icon: "square.and.arrow.up", title: "Share") {
//                    // TODO: Implement share functionality
//                }
//                
//                Spacer()
//            }
//            .padding(.top, 8)
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//        )
//    }
//}
//
//struct ActionButton: View {
//    let icon: String
//    let title: String
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 4) {
//                Image(systemName: icon)
//                    .font(.system(size: 20))
//                    .foregroundColor(.primary900)
//                
//                Text(title)
//                    .font(.caption2)
//                    .foregroundColor(.primary900)
//            }
//        }
//    }
//}
//
//// MARK: - Document Picker
//struct DocumentPickerView: UIViewControllerRepresentable {
//    let onDocumentPicked: (URL) -> Void
//    
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text])
//        picker.delegate = context.coordinator
//        picker.allowsMultipleSelection = false
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let parent: DocumentPickerView
//        
//        init(_ parent: DocumentPickerView) {
//            self.parent = parent
//        }
//        
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else { return }
//            parent.onDocumentPicked(url)
//        }
//    }
//}
//
//#Preview {
//    NavigationView {
//        PDFReaderView(book: Book(
//            id: 1,
//            title: "Sample Book",
//            author: "Sample Author",
//            coverURL: "",
//            downloadLinks: nil
//        ))
//    }
//}



//
//  PDFReaderView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 05/03/2025.
//

//import SwiftUI
//import PDFKit
//import Combine
//
//// MARK: - Models
//struct PDFModel: Identifiable {
//    let id = UUID()
//    let url: URL?
//    let fileName: String
//    var extractedText: String = ""
//    var pageCount: Int = 0
//}
//
//struct TranslationResult {
//    let originalText: String
//    let translatedText: String
//    let sourceLanguage: String
//    let targetLanguage: String
//}
//
//// MARK: - Services
//class PDFService {
//    static let shared = PDFService()
//    
//    private init() {}
//    
//    func loadPDF(from url: URL) -> AnyPublisher<PDFModel, APIError> {
//        return Future { promise in
//            DispatchQueue.global(qos: .background).async {
//                guard FileManager.default.fileExists(atPath: url.path) else {
//                    DispatchQueue.main.async {
//                        promise(.failure(APIError.invalidURL))
//                    }
//                    return
//                }
//                
//                guard let pdfDocument = PDFDocument(url: url) else {
//                    DispatchQueue.main.async {
//                        promise(.failure(APIError.invalidData))
//                    }
//                    return
//                }
//                
//                let extractedText = self.extractText(from: pdfDocument)
//                let model = PDFModel(
//                    url: url,
//                    fileName: url.lastPathComponent,
//                    extractedText: extractedText,
//                    pageCount: pdfDocument.pageCount
//                )
//                
//                DispatchQueue.main.async {
//                    promise(.success(model))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    func downloadBookPDF(for book: Book) -> AnyPublisher<URL, APIError> {
//        return Future { promise in
//            let sanitizedTitle = book.title.replacingOccurrences(of: " ", with: "_")
//                                          .replacingOccurrences(of: "/", with: "-")
//                                          .replacingOccurrences(of: ":", with: "_")
//            let filename = "book_\(book.id)_\(sanitizedTitle).pdf"
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let destinationURL = documentsDirectory.appendingPathComponent(filename)
//            
//            // Check if already downloaded
//            if FileManager.default.fileExists(atPath: destinationURL.path) {
//                let fileSize = (try? FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64) ?? 0
//                if fileSize > 1000 {
//                    DispatchQueue.main.async {
//                        promise(.success(destinationURL))
//                    }
//                    return
//                }
//            }
//            
//            // Try to download from available links
//            if let pdfURL = book.downloadLinks?.pdf,
//               let url = URL(string: pdfURL) {
//                self.downloadFile(from: url, to: destinationURL) { success in
//                    if success {
//                        promise(.success(destinationURL))
//                    } else {
//                        // Try HTML link if PDF direct download fails
//                        if let htmlURL = book.downloadLinks?.textHTML,
//                           let url = URL(string: htmlURL) {
//                            // For now, just use fallback since HTML conversion was complex
//                            self.useFallbackPDF(promise: promise)
//                        } else {
//                            self.useFallbackPDF(promise: promise)
//                        }
//                    }
//                }
//            } else {
//                self.useFallbackPDF(promise: promise)
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    private func extractText(from pdfDocument: PDFDocument) -> String {
//        var extractedText = ""
//        
//        for pageIndex in 0..<pdfDocument.pageCount {
//            guard let page = pdfDocument.page(at: pageIndex) else { continue }
//            if let pageContent = page.string {
//                extractedText += pageContent + "\n"
//            }
//        }
//        
//        return extractedText
//    }
//    
//    private func downloadFile(from url: URL, to destinationURL: URL, completion: @escaping (Bool) -> Void) {
//        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
//            guard let tempURL = tempURL, error == nil else {
//                DispatchQueue.main.async { completion(false) }
//                return
//            }
//            
//            do {
//                if FileManager.default.fileExists(atPath: destinationURL.path) {
//                    try FileManager.default.removeItem(at: destinationURL)
//                }
//                
//                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
//                
//                // Verify it's a valid PDF
//                if let pdfDocument = PDFDocument(url: destinationURL), pdfDocument.pageCount > 0 {
//                    DispatchQueue.main.async { completion(true) }
//                } else {
//                    try? FileManager.default.removeItem(at: destinationURL)
//                    DispatchQueue.main.async { completion(false) }
//                }
//            } catch {
//                DispatchQueue.main.async { completion(false) }
//            }
//        }.resume()
//    }
//    
//    private func useFallbackPDF(promise: @escaping (Result<URL, APIError>) -> Void) {
//        if let sampleURL = Bundle.main.url(forResource: "draft", withExtension: "pdf") {
//            DispatchQueue.main.async {
//                promise(.success(sampleURL))
//            }
//        } else {
//            DispatchQueue.main.async {
//                promise(.failure(APIError.invalidData))
//            }
//        }
//    }
//}
//
//class TranslationService {
//    static let shared = TranslationService()
//    
//    private init() {}
//    
//    func translateText(_ text: String,
//                      sourceLanguage: String = "en",
//                      targetLanguage: String = "ar") -> AnyPublisher<TranslationResult, APIError> {
//        return Future { promise in
//            // Simulate API call with delay
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                // Mock translation - replace with actual API implementation
//                let result = TranslationResult(
//                    originalText: text,
//                    translatedText: "ترجمة: \(text)", // Mock Arabic translation
//                    sourceLanguage: sourceLanguage,
//                    targetLanguage: targetLanguage
//                )
//                promise(.success(result))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    // TODO: Implement actual translation API using Alamofire
//    /*
//    func translateText(_ text: String,
//                      sourceLanguage: String = "en",
//                      targetLanguage: String = "ar") -> AnyPublisher<TranslationResult, APIError> {
//        let parameters: [String: Any] = [
//            "text": text,
//            "source": sourceLanguage,
//            "target": targetLanguage
//        ]
//        
//        return NetworkManager.shared.post(
//            endpoint: "translate",
//            parameters: parameters,
//            requiresAuth: false
//        )
//    }
//    */
//}
//
//// MARK: - ViewModels
//class PDFReaderViewModel: ObservableObject {
//    @Published var pdfModel: PDFModel?
//    @Published var selectedWord: String?
//    @Published var translationResult: TranslationResult?
//    @Published var isLoading = false
//    @Published var isTranslating = false
//    @Published var errorMessage: String?
//    @Published var showTranslation = false
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func loadPDF(from url: URL) {
//        isLoading = true
//        errorMessage = nil
//        
//        PDFService.shared.loadPDF(from: url)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] pdfModel in
//                    self?.pdfModel = pdfModel
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func loadBookPDF(for book: Book) {
//        isLoading = true
//        errorMessage = nil
//        
//        PDFService.shared.downloadBookPDF(for: book)
//            .flatMap { url in
//                PDFService.shared.loadPDF(from: url)
//            }
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] pdfModel in
//                    self?.pdfModel = pdfModel
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func translateWord(_ word: String) {
//        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        
//        selectedWord = word
//        isTranslating = true
//        
//        TranslationService.shared.translateText(word)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isTranslating = false
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                    }
//                },
//                receiveValue: { [weak self] result in
//                    self?.translationResult = result
//                    self?.showTranslation = true
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func dismissTranslation() {
//        showTranslation = false
//        selectedWord = nil
//        translationResult = nil
//    }
//}
//
//// MARK: - Main Views
//struct PDFReaderView: View {
//    @StateObject private var viewModel = PDFReaderViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    
//    let book: Book?
//    let pdfFile: PDFFile?
//    
//    init(book: Book) {
//        self.book = book
//        self.pdfFile = nil
//    }
//    
//    init(pdfFile: PDFFile) {
//        self.book = nil
//        self.pdfFile = pdfFile
//    }
//    
//    var body: some View {
//        ZStack {
//            if viewModel.isLoading {
//                LoadingView()
//            } else if let errorMessage = viewModel.errorMessage {
//                ErrorView(message: errorMessage) {
//                    loadContent()
//                }
//            } else if let pdfModel = viewModel.pdfModel {
//                PDFContentView(
//                    pdfModel: pdfModel,
//                    onWordSelected: { word in
//                        viewModel.translateWord(word)
//                    }
//                )
//            } else {
//                EmptyPDFView {
//                    loadContent()
//                }
//            }
//            
//            // Translation Overlay
//            if viewModel.showTranslation,
//               let result = viewModel.translationResult {
//                TranslationOverlayView(
//                    translationResult: result,
//                    isTranslating: viewModel.isTranslating,
//                    onDismiss: {
//                        viewModel.dismissTranslation()
//                    }
//                )
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(false)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Done") {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//        }
//        .onAppear {
//            loadContent()
//        }
//    }
//    
//    private func loadContent() {
//        if let book = book {
//            viewModel.loadBookPDF(for: book)
//        } else if let pdfFile = pdfFile {
//            let url = getURLForPDFFile(pdfFile)
//            if let validURL = url {
//                viewModel.loadPDF(from: validURL)
//            } else {
//                viewModel.errorMessage = "Could not locate PDF file"
//            }
//        }
//    }
//    
//    private func getURLForPDFFile(_ pdfFile: PDFFile) -> URL? {
//        if pdfFile.fileURL.starts(with: "/") {
//            return URL(fileURLWithPath: pdfFile.fileURL)
//        }
//        
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let localURL = documentsDirectory.appendingPathComponent(pdfFile.filename)
//        
//        if FileManager.default.fileExists(atPath: localURL.path) {
//            return localURL
//        }
//        
//        return nil
//    }
//}
//
//struct PDFContentView: View {
//    let pdfModel: PDFModel
//    let onWordSelected: (String) -> Void
//    
//    var body: some View {
//        VStack {
//            if let url = pdfModel.url {
//                EnhancedPDFView(
//                    pdfURL: url,
//                    onWordSelected: onWordSelected
//                )
//            } else {
//                Text("No PDF content available")
//                    .foregroundColor(.gray)
//                    .font(.headline)
//            }
//        }
//    }
//}
//
//struct EmptyPDFView: View {
//    let retryAction: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Image(systemName: "doc.text")
//                .font(.system(size: 50))
//                .foregroundColor(.gray)
//            
//            Text("No PDF Loaded")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            Text("Unable to load the PDF document")
//                .font(.body)
//                .foregroundColor(.gray)
//            
//            Button("Try Again") {
//                retryAction()
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .background(Color.primary900)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//        .padding()
//    }
//}
//
//// MARK: - PDF Viewer Component
//struct EnhancedPDFView: UIViewRepresentable {
//    let pdfURL: URL
//    let onWordSelected: (String) -> Void
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        
//        // Configure PDF View
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePage
//        pdfView.displayDirection = .vertical
//        pdfView.usePageViewController(true)
//        
//        // Enable zooming
//        pdfView.minScaleFactor = 0.5
//        pdfView.maxScaleFactor = 5.0
//        pdfView.scaleFactor = 1.0
//        
//        // Load document
//        if let document = PDFDocument(url: pdfURL) {
//            pdfView.document = document
//        }
//        
//        // Add gesture recognizers
//        let doubleTapGesture = UITapGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleDoubleTap(_:))
//        )
//        doubleTapGesture.numberOfTapsRequired = 2
//        pdfView.addGestureRecognizer(doubleTapGesture)
//        
//        let longPressGesture = UILongPressGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleLongPress(_:))
//        )
//        longPressGesture.minimumPressDuration = 0.5
//        pdfView.addGestureRecognizer(longPressGesture)
//        
//        return pdfView
//    }
//    
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        // Update if needed
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject {
//        var parent: EnhancedPDFView
//        
//        init(_ parent: EnhancedPDFView) {
//            self.parent = parent
//        }
//        
//        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//            extractWordAtGesture(gesture)
//        }
//        
//        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//            if gesture.state == .began {
//                extractWordAtGesture(gesture)
//            }
//        }
//        
//        private func extractWordAtGesture(_ gesture: UIGestureRecognizer) {
//            guard let pdfView = gesture.view as? PDFView else { return }
//            let point = gesture.location(in: pdfView)
//            
//            guard let page = pdfView.page(for: point, nearest: true) else { return }
//            let pagePoint = pdfView.convert(point, to: page)
//            
//            if let selection = page.selectionForWord(at: pagePoint),
//               let selectedText = selection.string?.trimmingCharacters(in: .whitespacesAndNewlines),
//               !selectedText.isEmpty {
//                parent.onWordSelected(selectedText)
//            }
//        }
//    }
//}
//
//// MARK: - Translation UI Components
//struct TranslationOverlayView: View {
//    let translationResult: TranslationResult
//    let isTranslating: Bool
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.3)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    onDismiss()
//                }
//            
//            VStack {
//                Spacer()
//                
//                TranslationPopupView(
//                    translationResult: translationResult,
//                    isTranslating: isTranslating,
//                    onDismiss: onDismiss
//                )
//                .padding(.horizontal, 20)
//                
//                Spacer()
//            }
//        }
//        .zIndex(1)
//    }
//}
//
//struct TranslationPopupView: View {
//    let translationResult: TranslationResult
//    let isTranslating: Bool
//    let onDismiss: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .trailing, spacing: 16) {
//            // Header with close button
//            HStack {
//                Text(translationResult.originalText)
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                    .lineLimit(2)
//                
//                Spacer()
//                
//                Button(action: onDismiss) {
//                    Image(systemName: "xmark")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Divider()
//            
//            // Translation content
//            HStack {
//                Spacer()
//                
//                if isTranslating {
//                    ProgressView()
//                        .scaleEffect(0.8)
//                } else {
//                    VStack(alignment: .trailing, spacing: 8) {
//                        Text(translationResult.translatedText)
//                            .font(.headline)
//                            .multilineTextAlignment(.trailing)
//                            .foregroundColor(.primary)
//                        
//                        Text("Arabic Translation")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            
//            // Action buttons
//            HStack(spacing: 20) {
//                ActionButton(icon: "speaker.wave.2", title: "Speak") {
//                    // TODO: Implement text-to-speech
//                }
//                
//                ActionButton(icon: "heart", title: "Save") {
//                    // TODO: Implement save to favorites
//                }
//                
//                ActionButton(icon: "square.and.arrow.up", title: "Share") {
//                    // TODO: Implement share functionality
//                }
//                
//                Spacer()
//            }
//            .padding(.top, 8)
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//        )
//    }
//}
//
//struct ActionButton: View {
//    let icon: String
//    let title: String
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 4) {
//                Image(systemName: icon)
//                    .font(.system(size: 20))
//                    .foregroundColor(.primary900)
//                
//                Text(title)
//                    .font(.caption2)
//                    .foregroundColor(.primary900)
//            }
//        }
//    }
//}
//
//// MARK: - Document Picker
//struct DocumentPickerView: UIViewControllerRepresentable {
//    let onDocumentPicked: (URL) -> Void
//    
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text])
//        picker.delegate = context.coordinator
//        picker.allowsMultipleSelection = false
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let parent: DocumentPickerView
//        
//        init(_ parent: DocumentPickerView) {
//            self.parent = parent
//        }
//        
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let originalURL = urls.first else {
//                print("No document selected")
//                return
//            }
//            
//            print("Document picked: \(originalURL.lastPathComponent)")
//            
//            // Secure access to the URL
//            let shouldStopAccessing = originalURL.startAccessingSecurityScopedResource()
//            
//            defer {
//                if shouldStopAccessing {
//                    originalURL.stopAccessingSecurityScopedResource()
//                }
//            }
//            
//            // Create a copy in the app's document directory
//            do {
//                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let destinationURL = documentsDirectory.appendingPathComponent(originalURL.lastPathComponent)
//                
//                // Remove any existing file with the same name
//                if FileManager.default.fileExists(atPath: destinationURL.path) {
//                    try FileManager.default.removeItem(at: destinationURL)
//                }
//                
//                // Copy the file
//                try FileManager.default.copyItem(at: originalURL, to: destinationURL)
//                print("File copied to app storage: \(destinationURL.path)")
//                
//                // Verify the file exists
//                if FileManager.default.fileExists(atPath: destinationURL.path) {
//                    // Use the local copy for upload
//                    DispatchQueue.main.async {
//                        self.parent.onDocumentPicked(destinationURL)
//                    }
//                } else {
//                    print("Error: File not found after copying")
//                }
//            } catch {
//                print("Error copying file: \(error)")
//            }
//        }
//        
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            print("Document picker was cancelled")
//        }
//    }
//}
//
//#Preview {
//    NavigationView {
//        PDFReaderView(book: Book(
//            id: 1,
//            title: "Sample Book",
//            author: "Sample Author",
//            coverURL: "",
//            downloadLinks: nil
//        ))
//    }
//}
