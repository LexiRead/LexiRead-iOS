



import SwiftUI
import Combine
import AVFoundation


// MARK: - ViewModel
class TranslateViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var translatedText: String = ""
    @Published var sourceLanguage: String = "English (USA)"
    @Published var targetLanguage: String = "Arabic(Egypt)"
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isPlayingAudio: Bool = false
    @Published var showLanguageSheet: Bool = false
    @Published var isSelectingSourceLanguage: Bool = true
    @Published var showCopiedFeedback: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var debounceTimer: Timer?
    
    let availableLanguages = [
        "English (USA)", "Arabic(Egypt)", "Spanish", "French", "German",
        "Chinese (Simplified)", "Japanese", "Korean", "Portuguese", "Russian",
        "Italian", "Dutch", "Hindi", "Turkish", "Polish"
    ]
    
    // MARK: - Methods
    func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        // Also swap the text if there's content
        if !inputText.isEmpty && !translatedText.isEmpty {
            let tempText = inputText
            inputText = translatedText
            translatedText = tempText
        }
    }
    
    func selectLanguage(_ language: String) {
        if isSelectingSourceLanguage {
            sourceLanguage = language
        } else {
            targetLanguage = language
        }
        showLanguageSheet = false
        
        // Re-translate if there's text
        if !inputText.isEmpty {
            translateText()
        }
    }
    
    func translateText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            translatedText = ""
            return
        }
        
        // Cancel previous timer
        debounceTimer?.invalidate()
        
        // Start new timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.performTranslation()
        }
    }
    
    private func performTranslation() {
        isLoading = true
        errorMessage = ""
        
        TranslationService.shared.translateTextWithTarget(
            inputText,
            targetLanguage: getLanguageCode(targetLanguage)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    
                    // Use fallback translation
                    if let self = self {
                        let fallback = TranslationService.shared.localTranslation(
                            self.inputText,
                            sourceLanguage: self.getLanguageCode(self.sourceLanguage),
                            targetLanguage: self.getLanguageCode(self.targetLanguage)
                        )
                        self.translatedText = fallback.translatedText
                    }
                }
            },
            receiveValue: { [weak self] result in
                self?.translatedText = result.translatedText
                print("Translation successful: \(result.translatedText)")
            }
        )
        .store(in: &cancellables)
    }
    
    func pasteFromClipboard() {
        if let clipboardContent = UIPasteboard.general.string {
            inputText = clipboardContent
            if !clipboardContent.isEmpty {
                translateText()
            }
        }
    }
    
    func copyTranslation() {
        guard !translatedText.isEmpty else { return }
        
        UIPasteboard.general.string = translatedText
        
        // Show feedback
        withAnimation {
            showCopiedFeedback = true
        }
        
        // Hide feedback after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showCopiedFeedback = false
            }
        }
    }
    
    func playAudio() {
        guard !translatedText.isEmpty else { return }
        
        isPlayingAudio = true
        
        TranslationService.shared.textToSpeech(
            text: translatedText,
            language: getLanguageCode(targetLanguage)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.isPlayingAudio = false
                    self?.errorMessage = "Audio playback failed: \(error.localizedDescription)"
                    self?.showError = true
                    print("Audio error: \(error)")
                }
            },
            receiveValue: { [weak self] audioURL in
                TranslationService.shared.playAudio(from: audioURL) {
                    DispatchQueue.main.async {
                        self?.isPlayingAudio = false
                    }
                }
            }
        )
        .store(in: &cancellables)
    }
    
    func shareTranslation() {
        guard !translatedText.isEmpty else { return }
        
        let shareText = "Original: \(inputText)\nTranslation: \(translatedText)"
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func getLanguageCode(_ language: String) -> String {
        switch language {
        case "English (USA)": return "en"
        case "Arabic(Egypt)": return "ar"
        case "Spanish": return "es"
        case "French": return "fr"
        case "German": return "de"
        case "Chinese (Simplified)": return "zh"
        case "Japanese": return "ja"
        case "Korean": return "ko"
        case "Portuguese": return "pt"
        case "Russian": return "ru"
        case "Italian": return "it"
        case "Dutch": return "nl"
        case "Hindi": return "hi"
        case "Turkish": return "tr"
        case "Polish": return "pl"
        default: return "en"
        }
    }
}

// MARK: - Main TranslateScreen View
struct TranslateScreen: View {
    @StateObject private var viewModel = TranslateViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Language Selection Section
                        languageSelectionSection
                        
                        // Input Text Section
                        inputTextSection
                        
                        // Translation Result Section
                        translationResultSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("LexiRead")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.primary900)]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showLanguageSheet) {
                LanguageSelectionSheet(viewModel: viewModel)
            }
            .onChange(of: viewModel.inputText) { newValue in
                viewModel.translateText()
            }
        }
    }
    
    // MARK: - Language Selection Section
    private var languageSelectionSection: some View {
        HStack(spacing: 12) {
            // Source Language
            languageButton(
                text: viewModel.sourceLanguage,
                isSource: true
            )
            
            // Swap Button
            Button(action: viewModel.swapLanguages) {
                Image("vector")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            
            // Target Language
            languageButton(
                text: viewModel.targetLanguage,
                isSource: false
            )
        }
    }
    
    private func languageButton(text: String, isSource: Bool) -> some View {
        Button(action: {
            viewModel.isSelectingSourceLanguage = isSource
            viewModel.showLanguageSheet = true
        }) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary900)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                )
        }
    }
    
    // MARK: - Input Text Section
    private var inputTextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Text Input Area
            ZStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(minHeight: 200)
                    
                    ZStack(alignment: .topLeading) {
                        if viewModel.inputText.isEmpty {
                            Text("Enter text...")
                                .font(.system(size: 36))
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .padding(.bottom, 60)
                        }
                        
                        TextEditor(text: $viewModel.inputText)
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .padding(.bottom, 60)
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                    }
                    
                    // Paste and Camera Buttons at bottom
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            Button(action: viewModel.pasteFromClipboard) {
                                HStack(spacing: 8) {
                                    Image(systemName: "list.clipboard")
                                        .font(.system(size: 20, weight: .medium))
                                    Text("Paste")
                                        .font(.system(size: 20, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.blue)
                                )
                            }
                            
                            Spacer()
                            
                            Image(systemName: "camera")
                                .font(.system(size: 20))
                                .foregroundColor(.primary900)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
    }
    
    // MARK: - Translation Result Section
    private var translationResultSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Language Label
            HStack {
                Text(viewModel.targetLanguage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary900)
                    .opacity(viewModel.inputText.isEmpty ? 0.5 : 1.0)
                Spacer()
            }
            
            // Translation Text Display
            ZStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(minHeight: 160)
                    
                    ZStack(alignment: .topLeading) {
                        Text(viewModel.isLoading ? viewModel.inputText : (viewModel.translatedText.isEmpty ? "" : viewModel.translatedText))
                            .foregroundColor(viewModel.isLoading ? .gray : .blue)
                            .font(.system(size: 24, weight: .regular))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: viewModel.isLoading ? .leading : .trailing)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .padding(.bottom, 60)
                    }
                    
                    // Action Buttons at bottom
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom, spacing: 20) {
                            // Play Audio Button
                            Button(action: viewModel.playAudio) {
                                VStack(spacing: 4) {
                                    if viewModel.isPlayingAudio {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                            .frame(width: 20, height: 20)
                                    } else {
                                        Image(systemName: "speaker.wave.2")
                                            .font(.system(size: 20))
                                            .foregroundColor(.primary900)
                                    }
                                    
                                    Text("Speak")
                                        .font(.caption2)
                                        .foregroundColor(.primary900)
                                }
                            }
                            .disabled(viewModel.isPlayingAudio || viewModel.translatedText.isEmpty)
                            
                            Spacer()
                            
                            // Copy Button
                            Button(action: viewModel.copyTranslation) {
                                VStack(spacing: 4) {
                                    Image(systemName: viewModel.showCopiedFeedback ? "checkmark" : "wallet.pass")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.showCopiedFeedback ? .green : .primary900)
                                    
                                    Text(viewModel.showCopiedFeedback ? "Copied!" : "Copy")
                                        .font(.caption2)
                                        .foregroundColor(viewModel.showCopiedFeedback ? .green : .primary900)
                                }
                            }
                            .disabled(viewModel.translatedText.isEmpty)
                            
                            // Share Button
                            Button(action: viewModel.shareTranslation) {
                                VStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 20))
                                        .foregroundColor(.primary900)
                                    
                                    Text("Share")
                                        .font(.caption2)
                                        .foregroundColor(.primary900)
                                }
                            }
                            .disabled(viewModel.translatedText.isEmpty)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Language Selection Sheet
struct LanguageSelectionSheet: View {
    @ObservedObject var viewModel: TranslateViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.availableLanguages, id: \.self) { language in
                            Button(action: {
                                viewModel.selectLanguage(language)
                            }) {
                                HStack {
                                    Text(language)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if (viewModel.isSelectingSourceLanguage && language == viewModel.sourceLanguage) ||
                                        (!viewModel.isSelectingSourceLanguage && language == viewModel.targetLanguage) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                        .fill(Color.blue.opacity(0.05))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showLanguageSheet = false
                    }
                    .foregroundColor(.primary900)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Select Language")
                        .font(.headline)
                        .foregroundColor(.primary900)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview
struct TranslateScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TranslateScreen()
        }
    }
}
