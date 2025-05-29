import SwiftUI
import Combine

// MARK: - Models
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let action: () -> Void
    let showChevron: Bool
    
    init(icon: String, title: String, showChevron: Bool = true, action: @escaping () -> Void = {}) {
        self.icon = icon
        self.title = title
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
}

// MARK: - ViewModel
class MoreScreenViewModel: ObservableObject {
    @Published var sections: [MenuSection]
    @Published var standaloneItems: [MenuItem]
    
    // Initialize cancellables before using it in closures
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // First initialize all properties
        self.sections = []
        self.standaloneItems = []
        
        // Then set up the sections with their items
        self.sections = [
            MenuSection(
                title: "Settings",
                icon: "gear",
                isExpanded: true,
                items: [
                    MenuItem(icon: "character.bubble", title: "Translation Language") {
                        // Translation Language screen
                    },
                    MenuItem(icon: "square.grid.2x2", title: "Translation Engine") {
                        // Translation Engine screen
                    }
                ]
            ),
            MenuSection(
                title: "Personal Info & Privacy",
                icon: "gear",
                isExpanded: false,
                items: [
                    MenuItem(icon: "person", title: "Personal Info") {
                        // Personal Info screen
                    },
                    MenuItem(icon: "lock", title: "Change Password") {
                        // Change Password screen
                    },
                    MenuItem(icon: "trash", title: "Delete Account") {
                        // Delete Account screen
                    }
                ]
            )
        ]
        
        // Set up standalone items
        self.standaloneItems = [
            MenuItem(icon: "person.2", title: "Invite Your Friends") {
                // Invite Friends screen
            },
            MenuItem(icon: "star", title: "Rate Us") {
                // Rate Us action
            },
            MenuItem(icon: "arrow.left.circle", title: "Logout", showChevron: true) { [weak self] in
                // Use weak self to avoid retain cycles
                guard let self = self else { return }
                
                // Logout action
                AuthService.shared.logout()
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        UserManager.shared.clearUserData()
                    }
                    .store(in: &self.cancellables)
            }
        ]
    }
    
    func toggleSection(_ sectionIndex: Int) {
        sections[sectionIndex].isExpanded.toggle()
    }
    
    func handleItemTap(title: String) {
        print("Navigating to: \(title)")
        // Navigation logic is handled in the individual MenuItem actions
    }
}

// MARK: - Views
struct MoreScreen: View {
    @StateObject private var viewModel = MoreScreenViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Lexi Bot Card
                        LexiBotCard()
                            .padding(.bottom, 8)
                        
                        // Collapsible Sections
                        ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                            CollapsibleSectionView(
                                section: section,
                                toggleAction: { viewModel.toggleSection(index) },
                                itemTapAction: viewModel.handleItemTap
                            )
                        }
                        
                        // Standalone Menu Items
                        ForEach(viewModel.standaloneItems) { item in
                            MenuItemView(item: item, itemTapAction: viewModel.handleItemTap)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Search action
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary900)
                    }
                }
            }
        }
    }
}

struct LexiBotCard: View {
    var body: some View {
        HStack {
            Image("chatbotmore")
                .resizable()
                .frame(width: 24, height: 24)
            Text("Lexi Bot")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(.natural100)
        .cornerRadius(12)
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
                HStack {
                    Image(systemName: section.icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(section.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(section.isExpanded ? 0 : 12, corners: [.bottomLeft, .bottomRight])
                .cornerRadius(12, corners: [.topLeft, .topRight])
            }
            
            // Section items (shown only when expanded)
            if section.isExpanded {
                VStack(spacing: 0) {
                    ForEach(section.items) { item in
                        MenuItemView(item: item, itemTapAction: itemTapAction)
                    }
                }
                .background(Color.white)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
        }
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
            HStack {
                Image(systemName: item.icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if item.showChevron {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
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
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct MoreScreen_Previews: PreviewProvider {
    static var previews: some View {
        MoreScreen()
    }
}
