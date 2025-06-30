//
//  WordListScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 29/06/2025.
//

//import SwiftUI
//import Combine
//
//// MARK: - Models
//struct WordListItem: Identifiable, Codable {
//    let id: Int
//    let originalText: String
//    let translatedText: String?  // Made optional to handle null values
//    let sourceLanguage: String
//    let targetLanguage: String
//    let audioUrl: String?
//    let document: String?
//    let isFavourite: Bool
//    let createdAt: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case originalText = "original_text"
//        case translatedText = "translated_text"
//        case sourceLanguage = "source_language"
//        case targetLanguage = "target_language"
//        case audioUrl = "audio_url"
//        case document
//        case isFavourite = "is_favourite"
//        case createdAt = "created_at"
//    }
//    
//    // Computed property for display date
//    var displayDate: String {
//        return createdAt ?? "Unknown date"
//    }
//    
//    // Computed property for display translation
//    var displayTranslatedText: String {
//        return translatedText ?? "No translation available"
//    }
//}
//
//struct WordListResponse: Codable {
//    let data: [WordListItem]
//}
//
//// MARK: - WordList Service
//class WordListService {
//    static let shared = WordListService()
//    
//    private init() {}
//    
//    func fetchWordList() -> AnyPublisher<[WordListItem], APIError> {
//        guard let url = URL(string: "\(APIConstants.baseURL)/wordlist") else {
//            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        // Add authentication headers
//        if let token = UserManager.shared.token {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { data, response -> Data in
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    throw APIError.invalidResponse
//                }
//                
//                print("WordList API Status: \(httpResponse.statusCode)")
//                
//                if !(200...299).contains(httpResponse.statusCode) {
//                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
//                    print("WordList API error: \(errorStr)")
//                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
//                }
//                
//                // Debug: Print raw response
//                if let responseString = String(data: data, encoding: .utf8) {
//                    print("WordList raw response: \(responseString)")
//                }
//                
//                return data
//            }
//            .tryMap { data -> [WordListItem] in
//                let decoder = JSONDecoder()
//                
//                // Try to decode as wrapped response first
//                do {
//                    let wrappedResponse = try decoder.decode(WordListResponse.self, from: data)
//                    print("Successfully decoded wrapped response with \(wrappedResponse.data.count) items")
//                    return wrappedResponse.data
//                } catch {
//                    print("Failed to decode as wrapped response: \(error)")
//                    
//                    // Try to decode as direct array
//                    do {
//                        let directResponse = try decoder.decode([WordListItem].self, from: data)
//                        print("Successfully decoded direct response with \(directResponse.count) items")
//                        return directResponse
//                    } catch {
//                        print("Failed to decode as direct array: \(error)")
//                        throw APIError.invalidData
//                    }
//                }
//            }
//            .mapError { error in
//                if let apiError = error as? APIError {
//                    return apiError
//                }
//                
//                if error is DecodingError {
//                    print("JSON parsing error: \(error)")
//                    return APIError.invalidData
//                }
//                
//                return APIError.mapError(error)
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    func deleteWordListItem(id: Int) -> AnyPublisher<Bool, APIError> {
//        guard let url = URL(string: "\(APIConstants.baseURL)/wordlist/\(id)") else {
//            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        
//        // Add authentication headers
//        if let token = UserManager.shared.token {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { data, response -> Bool in
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    throw APIError.invalidResponse
//                }
//                
//                print("Delete WordList API Status: \(httpResponse.statusCode)")
//                
//                if (200...299).contains(httpResponse.statusCode) {
//                    print("WordList item \(id) deleted successfully")
//                    return true
//                } else {
//                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
//                    print("Delete WordList API error: \(errorStr)")
//                    throw APIError.serverError("Failed to delete item")
//                }
//            }
//            .mapError { error in
//                APIError.mapError(error)
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    func toggleFavorite(id: Int) -> AnyPublisher<Bool, APIError> {
//        guard let url = URL(string: "\(APIConstants.baseURL)/favourites/toggle/\(id)") else {
//            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Add authentication headers
//        if let token = UserManager.shared.token {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { data, response -> Bool in
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    throw APIError.invalidResponse
//                }
//                
//                print("Toggle Favorite API Status: \(httpResponse.statusCode)")
//                
//                if (200...299).contains(httpResponse.statusCode) {
//                    print("Favorite status toggled for item \(id)")
//                    return true
//                } else {
//                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
//                    print("Toggle Favorite API error: \(errorStr)")
//                    throw APIError.serverError("Failed to toggle favorite")
//                }
//            }
//            .mapError { error in
//                APIError.mapError(error)
//            }
//            .eraseToAnyPublisher()
//    }
//}
//
//// MARK: - WordList ViewModel
//class WordListViewModel: ObservableObject {
//    @Published var wordList: [WordListItem] = []
//    @Published var isLoading: Bool = false
//    @Published var showError: Bool = false
//    @Published var errorMessage: String = ""
//    @Published var searchText: String = ""
//    @Published var playingAudioForItem: Int? = nil
//    @Published var isPlayingOriginal: Bool = false
//    @Published var showDeleteAlert: Bool = false
//    @Published var itemToDelete: WordListItem? = nil
//    @Published var showActionSheet: Bool = false
//    @Published var selectedItem: WordListItem? = nil
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    var filteredWordList: [WordListItem] {
//        if searchText.isEmpty {
//            return wordList
//        } else {
//            return wordList.filter { item in
//                item.originalText.localizedCaseInsensitiveContains(searchText) ||
//                (item.translatedText?.localizedCaseInsensitiveContains(searchText) ?? false)
//            }
//        }
//    }
//    
//    init() {
//        fetchWordList()
//    }
//    
//    func fetchWordList() {
//        isLoading = true
//        errorMessage = ""
//        
//        WordListService.shared.fetchWordList()
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    self?.isLoading = false
//                    
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = error.localizedDescription
//                        self?.showError = true
//                        print("WordList fetch error: \(error)")
//                    }
//                },
//                receiveValue: { [weak self] wordList in
//                    self?.wordList = wordList
//                    print("Fetched \(wordList.count) word list items")
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func deleteWordListItem(_ item: WordListItem) {
//        WordListService.shared.deleteWordListItem(id: item.id)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
//                        self?.showError = true
//                        print("Delete error: \(error)")
//                    }
//                },
//                receiveValue: { [weak self] success in
//                    if success {
//                        // Remove item from local list
//                        self?.wordList.removeAll { $0.id == item.id }
//                        print("Item deleted successfully")
//                    }
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func toggleFavorite(_ item: WordListItem) {
//        WordListService.shared.toggleFavorite(id: item.id)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case .failure(let error) = completion {
//                        self?.errorMessage = "Failed to toggle favorite: \(error.localizedDescription)"
//                        self?.showError = true
//                        print("Toggle favorite error: \(error)")
//                    }
//                },
//                receiveValue: { [weak self] success in
//                    if success {
//                        // Update item in local list
//                        if let index = self?.wordList.firstIndex(where: { $0.id == item.id }) {
//                            var updatedItem = item
//                            let newFavoriteStatus = !item.isFavourite
//                            
//                            // Create new item with updated favorite status
//                            let newItem = WordListItem(
//                                id: updatedItem.id,
//                                originalText: updatedItem.originalText,
//                                translatedText: updatedItem.translatedText,
//                                sourceLanguage: updatedItem.sourceLanguage,
//                                targetLanguage: updatedItem.targetLanguage,
//                                audioUrl: updatedItem.audioUrl,
//                                document: updatedItem.document,
//                                isFavourite: newFavoriteStatus,
//                                createdAt: updatedItem.createdAt
//                            )
//                            
//                            self?.wordList[index] = newItem
//                            print("Favorite status updated successfully")
//                        }
//                    }
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func showItemActions(_ item: WordListItem) {
//        selectedItem = item
//        showActionSheet = true
//    }
//    
//    func confirmDelete(_ item: WordListItem) {
//        itemToDelete = item
//        showDeleteAlert = true
//    }
//    
//    func playAudio(for item: WordListItem, isOriginal: Bool) {
//        let text = isOriginal ? item.originalText : (item.translatedText ?? item.originalText)
//        let language = isOriginal ? getLanguageCode(item.sourceLanguage) : getLanguageCode(item.targetLanguage)
//        
//        // Don't play audio if no text available
//        guard !text.isEmpty else {
//            errorMessage = "No text available for audio playback"
//            showError = true
//            return
//        }
//        
//        // Set playing state
//        playingAudioForItem = item.id
//        isPlayingOriginal = isOriginal
//        
//        print("Playing audio for: \(text) in language: \(language)")
//        
//        TranslationService.shared.textToSpeech(text: text, language: language)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case .failure(let error) = completion {
//                        self?.playingAudioForItem = nil
//                        self?.errorMessage = "Audio playback failed: \(error.localizedDescription)"
//                        self?.showError = true
//                        print("Audio error: \(error)")
//                    }
//                },
//                receiveValue: { [weak self] audioURL in
//                    TranslationService.shared.playAudio(from: audioURL) {
//                        DispatchQueue.main.async {
//                            self?.playingAudioForItem = nil
//                        }
//                    }
//                }
//            )
//            .store(in: &cancellables)
//    }
//    
//    func refreshWordList() {
//        fetchWordList()
//    }
//    
//    private func getLanguageCode(_ language: String) -> String {
//        switch language.lowercased() {
//        case "en", "english", "auto": return "en"
//        case "ar", "arabic": return "ar"
//        case "es", "spanish": return "es"
//        case "fr", "french": return "fr"
//        case "de", "german": return "de"
//        case "zh", "chinese": return "zh"
//        case "ja", "japanese": return "ja"
//        case "ko", "korean": return "ko"
//        case "pt", "portuguese": return "pt"
//        case "ru", "russian": return "ru"
//        case "it", "italian": return "it"
//        case "nl", "dutch": return "nl"
//        case "hi", "hindi": return "hi"
//        case "tr", "turkish": return "tr"
//        case "pl", "polish": return "pl"
//        default: return "en"
//        }
//    }
//}
//
//// MARK: - WordList Screen View
//struct WordListScreen: View {
//    @StateObject private var viewModel = WordListViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.white
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    // Search Bar
//                    searchBar
//                    
//                    if viewModel.isLoading && viewModel.wordList.isEmpty {
//                        // Loading State
//                        VStack(spacing: 20) {
//                            Spacer()
//                            ProgressView()
//                                .scaleEffect(1.5)
//                                .tint(.primary900)
//                            
//                            Text("Loading word list...")
//                                .font(.headline)
//                                .foregroundColor(.gray)
//                            Spacer()
//                        }
//                    } else if viewModel.wordList.isEmpty {
//                        // Empty State
//                        VStack(spacing: 20) {
//                            Spacer()
//                            Image(systemName: "text.bubble")
//                                .font(.system(size: 60))
//                                .foregroundColor(.gray.opacity(0.5))
//                            
//                            Text("No translations yet")
//                                .font(.title2)
//                                .fontWeight(.medium)
//                                .foregroundColor(.gray)
//                            
//                            Text("Start translating to build your word list")
//                                .font(.body)
//                                .foregroundColor(.gray.opacity(0.7))
//                                .multilineTextAlignment(.center)
//                            Spacer()
//                        }
//                        .padding(.horizontal, 40)
//                    } else {
//                        // Word List Content
//                        wordListContent
//                    }
//                }
//            }
//            .navigationTitle("Word List")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: viewModel.refreshWordList) {
//                        Image(systemName: "arrow.clockwise")
//                            .foregroundColor(.primary900)
//                    }
//                }
//            }
//            .alert("Error", isPresented: $viewModel.showError) {
//                Button("OK") { }
//            } message: {
//                Text(viewModel.errorMessage)
//            }
//            .alert("Delete Translation", isPresented: $viewModel.showDeleteAlert) {
//                Button("Cancel", role: .cancel) {
//                    viewModel.itemToDelete = nil
//                }
//                Button("Delete", role: .destructive) {
//                    if let item = viewModel.itemToDelete {
//                        viewModel.deleteWordListItem(item)
//                    }
//                    viewModel.itemToDelete = nil
//                }
//            } message: {
//                Text("Are you sure you want to delete this translation? This action cannot be undone.")
//            }
//            .actionSheet(isPresented: $viewModel.showActionSheet) {
//                ActionSheet(
//                    title: Text("Translation Options"),
//                    buttons: [
//                        .default(Text(viewModel.selectedItem?.isFavourite == true ? "Remove from Favorites" : "Add to Favorites")) {
//                            if let item = viewModel.selectedItem {
//                                viewModel.toggleFavorite(item)
//                            }
//                        },
//                        .destructive(Text("Delete Translation")) {
//                            if let item = viewModel.selectedItem {
//                                viewModel.confirmDelete(item)
//                            }
//                        },
//                        .cancel()
//                    ]
//                )
//            }
//        }
//    }
//    
//    // MARK: - Search Bar
//    private var searchBar: some View {
//        HStack(spacing: 12) {
//            HStack(spacing: 8) {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//                
//                TextField("Search translations...", text: $viewModel.searchText)
//                    .font(.system(size: 16))
//                
//                if !viewModel.searchText.isEmpty {
//                    Button(action: {
//                        viewModel.searchText = ""
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 10)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.gray.opacity(0.1))
//            )
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 10)
//    }
//    
//    // MARK: - Word List Content
//    private var wordListContent: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                ForEach(viewModel.filteredWordList) { item in
//                    WordListItemView(
//                        item: item,
//                        viewModel: viewModel
//                    )
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//        }
//        .refreshable {
//            viewModel.refreshWordList()
//        }
//    }
//}
//
//// MARK: - Word List Item View
//struct WordListItemView: View {
//    let item: WordListItem
//    @ObservedObject var viewModel: WordListViewModel
//    
//    private var isPlayingOriginal: Bool {
//        viewModel.playingAudioForItem == item.id && viewModel.isPlayingOriginal
//    }
//    
//    private var isPlayingTranslated: Bool {
//        viewModel.playingAudioForItem == item.id && !viewModel.isPlayingOriginal
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Header with timestamp and actions
//            HStack {
//                Text(item.displayDate)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                
//                Spacer()
//                
//                HStack(spacing: 12) {
//                    // Favorite button
//                    Button(action: {
//                        viewModel.toggleFavorite(item)
//                    }) {
//                        Image(systemName: item.isFavourite ? "heart.fill" : "heart")
//                            .foregroundColor(item.isFavourite ? .red : .gray)
//                            .font(.system(size: 16))
//                    }
//                    
//                    // More options button
//                    Button(action: {
//                        viewModel.showItemActions(item)
//                    }) {
//                        Image(systemName: "ellipsis")
//                            .foregroundColor(.gray)
//                            .font(.system(size: 16))
//                    }
//                }
//            }
//            
//            // Original Text Section
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text("Original (\(item.sourceLanguage.uppercased()))")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .fontWeight(.medium)
//                    
//                    Spacer()
//                    
//                    // Audio button for original text
//                    Button(action: {
//                        viewModel.playAudio(for: item, isOriginal: true)
//                    }) {
//                        if isPlayingOriginal {
//                            ProgressView()
//                                .scaleEffect(0.8)
//                                .frame(width: 20, height: 20)
//                        } else {
//                            Image(systemName: "speaker.wave.2")
//                                .font(.system(size: 16))
//                                .foregroundColor(.primary900)
//                        }
//                    }
//                    .disabled(isPlayingOriginal || isPlayingTranslated)
//                }
//                
//                Text(item.originalText)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.leading)
//            }
//            
//            // Divider
//            Rectangle()
//                .fill(Color.gray.opacity(0.3))
//                .frame(height: 1)
//            
//            // Translated Text Section
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text("Translation (\(item.targetLanguage.uppercased()))")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .fontWeight(.medium)
//                    
//                    Spacer()
//                    
//                    // Audio button for translated text
//                    Button(action: {
//                        viewModel.playAudio(for: item, isOriginal: false)
//                    }) {
//                        if isPlayingTranslated {
//                            ProgressView()
//                                .scaleEffect(0.8)
//                                .frame(width: 20, height: 20)
//                        } else {
//                            Image(systemName: "speaker.wave.2")
//                                .font(.system(size: 16))
//                                .foregroundColor(item.translatedText != nil ? .primary900 : .gray)
//                        }
//                    }
//                    .disabled(isPlayingOriginal || isPlayingTranslated || item.translatedText == nil)
//                }
//                
//                Text(item.displayTranslatedText)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(item.translatedText != nil ? .blue : .gray)
//                    .multilineTextAlignment(.trailing)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white)
//                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - API Constants Extension
//extension APIConstants.Endpoints {
//    static let wordList = "wordlist"
//}
//
//// MARK: - Preview
//struct WordListScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        WordListScreen()
//    }
//}


import SwiftUI
import Combine

// MARK: - Models
struct WordListItem: Identifiable, Codable {
    let id: Int
    let originalText: String
    let translatedText: String?  // Made optional to handle null values
    let sourceLanguage: String
    let targetLanguage: String
    let audioUrl: String?
    let document: String?
    let isFavourite: Bool
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case originalText = "original_text"
        case translatedText = "translated_text"
        case sourceLanguage = "source_language"
        case targetLanguage = "target_language"
        case audioUrl = "audio_url"
        case document
        case isFavourite = "is_favourite"
        case createdAt = "created_at"
    }
    
    // Computed property for display date
    var displayDate: String {
        return createdAt ?? "Unknown date"
    }
    
    // Computed property for display translation
    var displayTranslatedText: String {
        return translatedText ?? "No translation available"
    }
}

struct WordListResponse: Codable {
    let data: [WordListItem]
}

// MARK: - WordList Service
class WordListService {
    static let shared = WordListService()
    
    private init() {}
    
    func fetchWordList() -> AnyPublisher<[WordListItem], APIError> {
        guard let url = URL(string: "\(APIConstants.baseURL)/wordlist") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authentication headers
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("WordList API Status: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("WordList API error: \(errorStr)")
                    throw APIError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
                
                // Debug: Print raw response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("WordList raw response: \(responseString)")
                }
                
                return data
            }
            .tryMap { data -> [WordListItem] in
                let decoder = JSONDecoder()
                
                // Try to decode as wrapped response first
                do {
                    let wrappedResponse = try decoder.decode(WordListResponse.self, from: data)
                    print("Successfully decoded wrapped response with \(wrappedResponse.data.count) items")
                    return wrappedResponse.data
                } catch {
                    print("Failed to decode as wrapped response: \(error)")
                    
                    // Try to decode as direct array
                    do {
                        let directResponse = try decoder.decode([WordListItem].self, from: data)
                        print("Successfully decoded direct response with \(directResponse.count) items")
                        return directResponse
                    } catch {
                        print("Failed to decode as direct array: \(error)")
                        throw APIError.invalidData
                    }
                }
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                
                if error is DecodingError {
                    print("JSON parsing error: \(error)")
                    return APIError.invalidData
                }
                
                return APIError.mapError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteWordListItem(id: Int) -> AnyPublisher<Bool, APIError> {
        guard let url = URL(string: "\(APIConstants.baseURL)/wordlist/\(id)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Add authentication headers
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("Delete WordList API Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("WordList item \(id) deleted successfully")
                    return true
                } else {
                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Delete WordList API error: \(errorStr)")
                    throw APIError.serverError("Failed to delete item")
                }
            }
            .mapError { error in
                APIError.mapError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func toggleFavorite(id: Int) -> AnyPublisher<Bool, APIError> {
        guard let url = URL(string: "\(APIConstants.baseURL)/favourites/toggle/\(id)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add authentication headers
        if let token = UserManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                print("Toggle Favorite API Status: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("Favorite status toggled for item \(id)")
                    return true
                } else {
                    let errorStr = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("Toggle Favorite API error: \(errorStr)")
                    throw APIError.serverError("Failed to toggle favorite")
                }
            }
            .mapError { error in
                APIError.mapError(error)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - WordList ViewModel
class WordListViewModel: ObservableObject {
    @Published var wordList: [WordListItem] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var searchText: String = ""
    @Published var playingAudioForItem: Int? = nil
    @Published var isPlayingOriginal: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var itemToDelete: WordListItem? = nil
    @Published var showActionSheet: Bool = false
    @Published var selectedItem: WordListItem? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    var filteredWordList: [WordListItem] {
        if searchText.isEmpty {
            return wordList
        } else {
            return wordList.filter { item in
                item.originalText.localizedCaseInsensitiveContains(searchText) ||
                (item.translatedText?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    init() {
        fetchWordList()
    }
    
    func fetchWordList() {
        isLoading = true
        errorMessage = ""
        
        WordListService.shared.fetchWordList()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                        print("WordList fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] wordList in
                    self?.wordList = wordList
                    print("Fetched \(wordList.count) word list items")
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteWordListItem(_ item: WordListItem) {
        WordListService.shared.deleteWordListItem(id: item.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                        self?.showError = true
                        print("Delete error: \(error)")
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        // Remove item from local list
                        self?.wordList.removeAll { $0.id == item.id }
                        print("Item deleted successfully")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite(_ item: WordListItem) {
        WordListService.shared.toggleFavorite(id: item.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to toggle favorite: \(error.localizedDescription)"
                        self?.showError = true
                        print("Toggle favorite error: \(error)")
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        // Update item in local list
                        if let index = self?.wordList.firstIndex(where: { $0.id == item.id }) {
                            var updatedItem = item
                            let newFavoriteStatus = !item.isFavourite
                            
                            // Create new item with updated favorite status
                            let newItem = WordListItem(
                                id: updatedItem.id,
                                originalText: updatedItem.originalText,
                                translatedText: updatedItem.translatedText,
                                sourceLanguage: updatedItem.sourceLanguage,
                                targetLanguage: updatedItem.targetLanguage,
                                audioUrl: updatedItem.audioUrl,
                                document: updatedItem.document,
                                isFavourite: newFavoriteStatus,
                                createdAt: updatedItem.createdAt
                            )
                            
                            self?.wordList[index] = newItem
                            print("Favorite status updated successfully")
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func showItemActions(_ item: WordListItem) {
        selectedItem = item
        showActionSheet = true
    }
    
    func confirmDelete(_ item: WordListItem) {
        itemToDelete = item
        showDeleteAlert = true
    }
    
    func playAudio(for item: WordListItem, isOriginal: Bool) {
        let text = isOriginal ? item.originalText : (item.translatedText ?? item.originalText)
        let language = isOriginal ? getLanguageCode(item.sourceLanguage) : getLanguageCode(item.targetLanguage)
        
        // Don't play audio if no text available
        guard !text.isEmpty else {
            errorMessage = "No text available for audio playback"
            showError = true
            return
        }
        
        // Set playing state
        playingAudioForItem = item.id
        isPlayingOriginal = isOriginal
        
        print("Playing audio for: \(text) in language: \(language)")
        
        TranslationService.shared.textToSpeech(text: text, language: language)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.playingAudioForItem = nil
                        self?.errorMessage = "Audio playback failed: \(error.localizedDescription)"
                        self?.showError = true
                        print("Audio error: \(error)")
                    }
                },
                receiveValue: { [weak self] audioURL in
                    TranslationService.shared.playAudio(from: audioURL) {
                        DispatchQueue.main.async {
                            self?.playingAudioForItem = nil
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshWordList() {
        fetchWordList()
    }
    
    private func getLanguageCode(_ language: String) -> String {
        switch language.lowercased() {
        case "en", "english", "auto": return "en"
        case "ar", "arabic": return "ar"
        case "es", "spanish": return "es"
        case "fr", "french": return "fr"
        case "de", "german": return "de"
        case "zh", "chinese": return "zh"
        case "ja", "japanese": return "ja"
        case "ko", "korean": return "ko"
        case "pt", "portuguese": return "pt"
        case "ru", "russian": return "ru"
        case "it", "italian": return "it"
        case "nl", "dutch": return "nl"
        case "hi", "hindi": return "hi"
        case "tr", "turkish": return "tr"
        case "pl", "polish": return "pl"
        default: return "en"
        }
    }
}

// MARK: - WordList Screen View
struct WordListScreen: View {
    @StateObject private var viewModel = WordListViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient using app colors
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primary900.opacity(0.05),
                        Color.darkerBlue.opacity(0.03),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    if viewModel.isLoading && viewModel.wordList.isEmpty {
                        // Loading State
                        VStack(spacing: 20) {
                            Spacer()
                            ZStack {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.primary900, .darkerBlue]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                                    .frame(width: 60, height: 60)
                                
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.primary900)
                            }
                            
                            Text("Loading word list...")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary900)
                            Spacer()
                        }
                    } else if viewModel.wordList.isEmpty {
                        // Empty State
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.primary900.opacity(0.15), .darkerBlue.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "text.bubble")
                                    .font(.system(size: 50, weight: .light))
                                    .foregroundColor(.primary900)
                            }
                            
                            VStack(spacing: 12) {
                                Text("No translations yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary900)
                                
                                Text("Start translating to build your word list")
                                    .font(.body)
                                    .foregroundColor(.lrGray)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        // Word List Content
                        wordListContent
                    }
                }
            }
            .navigationTitle("Word List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshWordList) {
                        ZStack {
                            Circle()
                                .fill(Color.primary900.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.primary900)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Delete Translation", isPresented: $viewModel.showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    viewModel.itemToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let item = viewModel.itemToDelete {
                        viewModel.deleteWordListItem(item)
                    }
                    viewModel.itemToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this translation? This action cannot be undone.")
            }
            .actionSheet(isPresented: $viewModel.showActionSheet) {
                ActionSheet(
                    title: Text("Translation Options"),
                    buttons: [
                        .default(Text(viewModel.selectedItem?.isFavourite == true ? "Remove from Favorites" : "Add to Favorites")) {
                            if let item = viewModel.selectedItem {
                                viewModel.toggleFavorite(item)
                            }
                        },
                        .destructive(Text("Delete Translation")) {
                            if let item = viewModel.selectedItem {
                                viewModel.confirmDelete(item)
                            }
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primary900.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary900)
                        .font(.system(size: 14, weight: .medium))
                }
                
                TextField("Search translations...", text: $viewModel.searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary900)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.lrGray.opacity(0.3))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.lrGray)
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .primary900.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Word List Content
    private var wordListContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredWordList) { item in
                    WordListItemView(
                        item: item,
                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .refreshable {
            viewModel.refreshWordList()
        }
    }
}

// MARK: - Word List Item View
struct WordListItemView: View {
    let item: WordListItem
    @ObservedObject var viewModel: WordListViewModel
    
    private var isPlayingOriginal: Bool {
        viewModel.playingAudioForItem == item.id && viewModel.isPlayingOriginal
    }
    
    private var isPlayingTranslated: Bool {
        viewModel.playingAudioForItem == item.id && !viewModel.isPlayingOriginal
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with timestamp and actions
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.darkerBlue.opacity(0.3))
                        .frame(width: 8, height: 8)
                    
                    Text(item.displayDate)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary900)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Favorite button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.toggleFavorite(item)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(item.isFavourite ? Color.lrYellow.opacity(0.2) : Color.lrGray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: item.isFavourite ? "heart.fill" : "heart")
                                .foregroundColor(item.isFavourite ? Color.red : .primary900 )
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .scaleEffect(item.isFavourite ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isFavourite)
                    
                    // More options button
                    Button(action: {
                        viewModel.showItemActions(item)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.lrGray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "ellipsis")
                                .foregroundColor(.primary900)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                }
            }
            
            // Original Text Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.primary900)
                            .frame(width: 6, height: 6)
                        
                        Text("Original")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary900)
                    }
                    
                    Spacer()
                    
                    // Audio button for original text
                    Button(action: {
                        viewModel.playAudio(for: item, isOriginal: true)
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.primary900.opacity(0.15), .primary900.opacity(0.08)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            if isPlayingOriginal {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.primary900)
                            } else {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary900)
                            }
                        }
                    }
                    .disabled(isPlayingOriginal || isPlayingTranslated)
                    .scaleEffect(isPlayingOriginal ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlayingOriginal)
                }
                
                Text(item.originalText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary900.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary900.opacity(0.15), lineWidth: 1)
                            )
                    )
            }
            
            // Divider with gradient using app colors
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .primary900.opacity(0.2), .darkerBlue.opacity(0.2), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }
            
            // Translated Text Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.translatedText != nil ? Color.darkerBlue : Color.lrGray)
                            .frame(width: 6, height: 6)
                        
                        Text("Translation (\(item.targetLanguage.uppercased()))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(item.translatedText != nil ? .darkerBlue : .lrGray)
                    }
                    
                    Spacer()
                    
                    // Audio button for translated text
                    Button(action: {
                        viewModel.playAudio(for: item, isOriginal: false)
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            (item.translatedText != nil ? Color.darkerBlue : Color.lrGray).opacity(0.15),
                                            (item.translatedText != nil ? Color.darkerBlue : Color.lrGray).opacity(0.08)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            if isPlayingTranslated {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.darkerBlue)
                            } else {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(item.translatedText != nil ? .darkerBlue : .lrGray)
                            }
                        }
                    }
                    .disabled(isPlayingOriginal || isPlayingTranslated || item.translatedText == nil)
                    .scaleEffect(isPlayingTranslated ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlayingTranslated)
                }
                
                Text(item.displayTranslatedText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.translatedText != nil ? .darkerBlue : .lrGray)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((item.translatedText != nil ? Color.darkerBlue : Color.lrGray).opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((item.translatedText != nil ? Color.darkerBlue : Color.lrGray).opacity(0.15), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .primary900.opacity(0.08), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .primary900.opacity(0.08),
                                    .darkerBlue.opacity(0.06),
                                    .clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(item.isFavourite ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: item.isFavourite)
    }
}

// MARK: - API Constants Extension
extension APIConstants.Endpoints {
    static let wordList = "wordlist"
}

// MARK: - Preview
struct WordListScreen_Previews: PreviewProvider {
    static var previews: some View {
        WordListScreen()
    }
}
