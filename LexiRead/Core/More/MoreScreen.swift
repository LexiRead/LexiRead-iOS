


import SwiftUI
import Combine

// MARK: - Models
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let action: () -> Void
    let showChevron: Bool
    let iconColor: Color
    let backgroundColor: Color
    
    init(icon: String, title: String, iconColor: Color = .blue, backgroundColor: Color = Color.blue.opacity(0.1), showChevron: Bool = true, action: @escaping () -> Void = {}) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.showChevron = showChevron
        self.action = action
    }
}

struct MenuSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var isExpanded: Bool
    let items: [MenuItem]
    let iconColor: Color
    let backgroundColor: Color
    
    init(title: String, icon: String, isExpanded: Bool = false, iconColor: Color = .blue, backgroundColor: Color = Color.blue.opacity(0.1), items: [MenuItem]) {
        self.title = title
        self.icon = icon
        self.isExpanded = isExpanded
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.items = items
    }
}




// MARK: - API Models for Delete Account
struct DeleteAccountResponse: Codable {
    let data: String
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

// MARK: - Updated APIConstants
extension APIConstants.Endpoints {
    static let deleteAccount = "auth/deleteAccount"
}

// MARK: - NetworkService Extension
extension NetworkService {
    func deleteAccount(completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = APIConstants.Endpoints.deleteAccount
        let emptyParameters: [String: Any] = [:]
        
        NetworkManager.shared.delete<DeleteAccountResponse>(
            endpoint: endpoint,
            parameters: emptyParameters,
            requiresAuth: true
        ) { (result: Result<DeleteAccountResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - AuthService Extension
extension AuthService {
    func deleteAccount() -> AnyPublisher<String, APIError> {
        return Future<String, APIError> { promise in
            NetworkService.shared.deleteAccount { result in
                switch result {
                case .success(let message):
                    // Clear user data locally after successful deletion
                    UserManager.shared.clearUserData()
                    promise(.success(message))
                case .failure(let error):
                    let apiError = APIError.mapError(error)
                    promise(.failure(apiError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Updated MoreScreenViewModel
class MoreScreenViewModel: ObservableObject {
    @Published var sections: [MenuSection]
    @Published var standaloneItems: [MenuItem]
    @Published var showDeleteConfirmation = false
    @Published var showDeleteAlert = false
    @Published var deleteAlertTitle = ""
    @Published var deleteAlertMessage = ""
    @Published var isLoading = false
    @Published var navigateToForgotPassword = false
    @Published var navigateToPersonalInfo = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.sections = []
        self.standaloneItems = []
        
        // Settings Section - Initially Expanded
        self.sections = [
            MenuSection(
                title: "Settings",
                icon: "gear",
                isExpanded: true,
                iconColor: .primary900,
                backgroundColor: Color.primary900.opacity(0.1),
                items: [
                    MenuItem(
                        icon: "character.bubble",
                        title: "Translation Language",
                        iconColor: .primary900,
                        backgroundColor: Color.primary900.opacity(0.1)
                    ) {
                        // Translation Language screen
                    },
                    MenuItem(
                        icon: "square.grid.2x2",
                        title: "Translation Engine",
                        iconColor: .primary900,
                        backgroundColor: Color.primary900.opacity(0.1)
                    ) {
                        // Translation Engine screen
                    }
                ]
            ),
            MenuSection(
                title: "Personal Info & Privacy",
                icon: "gear",
                isExpanded: false,
                iconColor: .primary900,
                backgroundColor: Color.primary900.opacity(0.1),
                items: [
                    MenuItem(
                        icon: "person",
                        title: "Personal Info",
                        iconColor: .primary900,
                        backgroundColor: Color.primary900.opacity(0.1)
                    ) { [weak self] in
                        self?.navigateToPersonalInfo = true
                    },
                    MenuItem(
                        icon: "lock",
                        title: "Change Password",
                        iconColor: .primary900,
                        backgroundColor: Color.primary900.opacity(0.1)
                    ) { [weak self] in
                        self?.navigateToForgotPassword = true
                    },
                    MenuItem(
                        icon: "trash",
                        title: "Delete Account",
                        iconColor: .red,
                        backgroundColor: Color.red.opacity(0.1)
                    ) { [weak self] in
                        self?.showDeleteConfirmation = true
                    }
                ]
            )
        ]
        
        // Standalone Items
        self.standaloneItems = [
            MenuItem(
                icon: "person.2",
                title: "Invite Your Friends",
                iconColor: .primary900,
                backgroundColor: Color.primary900.opacity(0.1)
            ) {
                // Invite Friends screen
            },
            MenuItem(
                icon: "star",
                title: "Rate Us",
                iconColor: .lrYellow,
                backgroundColor: Color.lrYellow.opacity(0.1)
            ) {
                // Rate Us action
            },
            MenuItem(
                icon: "arrow.left.circle",
                title: "Logout",
                iconColor: .red,
                backgroundColor: Color.red.opacity(0.1),
                showChevron: true
            ) { [weak self] in
                self?.performLogout()
            }
        ]
    }
    
    func toggleSection(_ sectionIndex: Int) {
        sections[sectionIndex].isExpanded.toggle()
    }
    
    func handleItemTap(title: String) {
        print("Navigating to: \(title)")
    }
    
    func performLogout() {
//        isLoading = true
//        
//        AuthService.shared.logout()
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { [weak self] _ in
//                    self?.isLoading = false
//                },
//                receiveValue: { _ in
//                    UserManager.shared.clearUserData()
//                    AppState.shared.logout()
//                }
//            )
//            .store(in: &cancellables)
    }
    
    func deleteAccount() {
        isLoading = true
        
        AuthService.shared.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.deleteAlertTitle = "Error"
                        self.deleteAlertMessage = error.localizedDescription
                        self.showDeleteAlert = true
                    }
                },
                receiveValue: { [weak self] message in
                    guard let self = self else { return }
                    
                    // Account deleted successfully
                    self.deleteAlertTitle = "Account Deleted"
                    self.deleteAlertMessage = message
                    self.showDeleteAlert = true

                    // Clear app state and navigate to login
                    AppState.shared.logout()
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Updated MoreScreen with Navigation
struct MoreScreen: View {
    @StateObject private var viewModel = MoreScreenViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Lexi Bot Card
                        NavigationLink(destination: ChatScreen()) {
                            LexiBotCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Collapsible Sections
                        ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                            CollapsibleSectionView(
                                section: section,
                                toggleAction: { viewModel.toggleSection(index) },
                                itemTapAction: viewModel.handleItemTap
                            )
                        }
                        
                        // Standalone Menu Items
                        VStack(spacing: 12) {
                            ForEach(viewModel.standaloneItems) { item in
                                MenuItemView(item: item, itemTapAction: viewModel.handleItemTap)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                
                // Loading Overlay
                if viewModel.isLoading {
                    LoadingView()
                }
                
                // Hidden NavigationLinks for navigation
                NavigationLink(
                    destination: ForgotPasswordScreen(),
                    isActive: $viewModel.navigateToForgotPassword
                ) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(
                    destination: PersonalInfoScreen(),
                    isActive: $viewModel.navigateToPersonalInfo
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.primary900)
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete Account",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                viewModel.deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
        }
        .alert(
            viewModel.deleteAlertTitle,
            isPresented: $viewModel.showDeleteAlert
        ) {
            Button("OK") {
                // If account was successfully deleted, user will be automatically logged out
            }
        } message: {
            Text(viewModel.deleteAlertMessage)
        }
    }
}

// MARK: - Rest of the UI Components remain the same
struct LexiBotCard: View {
    var body: some View {
        HStack(spacing: 12) {
            // Bot Icon
            Image(systemName: "message.circle.fill")
                .font(.title2)
                .foregroundColor(.primary900)
                .frame(width: 32, height: 32)
            
            Text("Lexi Bot")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct CollapsibleSectionView: View {
    let section: MenuSection
    let toggleAction: () -> Void
    let itemTapAction: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: toggleAction) {
                HStack(spacing: 12) {
                    // Section Icon
                    Image(systemName: section.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(section.iconColor)
                        .frame(width: 32, height: 32)
                        .background(section.backgroundColor)
                        .clipShape(Circle())
                    
                    Text(section.title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .clipShape(
                    section.isExpanded ?
                    RoundedCorner(radius: 12, corners: [.topLeft, .topRight]) :
                    RoundedCorner(radius: 12, corners: .allCorners)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Section Items (shown only when expanded)
            if section.isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 0) {
                            // Divider before each item except the first
                            if index > 0 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                            
                            Button(action: {
                                item.action()
                                itemTapAction(item.title)
                            }) {
                                HStack(spacing: 12) {
                                    // Item Icon
                                    Image(systemName: item.icon)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(item.iconColor)
                                        .frame(width: 32, height: 32)
                                        .background(item.backgroundColor)
                                        .clipShape(Circle())
                                    
                                    Text(item.title)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if item.showChevron {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight]))
            }
        }
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MenuItemView: View {
    let item: MenuItem
    let itemTapAction: (String) -> Void
    
    var body: some View {
        Button(action: {
            item.action()
            itemTapAction(item.title)
        }) {
            HStack(spacing: 12) {
                // Item Icon
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.iconColor)
                    .frame(width: 32, height: 32)
                    .background(item.backgroundColor)
                    .clipShape(Circle())
                
                Text(item.title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if item.showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct MoreScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoreScreen()
    }
}
