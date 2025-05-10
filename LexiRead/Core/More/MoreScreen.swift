//
//  MoreScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/04/2025.
//
import SwiftUI

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
    
    init() {
        // Initialize with collapsible sections and their items
        self.sections = [
            MenuSection(
                title: "Settings",
                icon: "gearshape",
                isExpanded: false,
                items: [
                    MenuItem(icon: "globe", title: "Language"),
                    MenuItem(icon: "doc.text.magnifyingglass", title: "Translation Source"),
                    MenuItem(icon: "arrow.triangle.2.circlepath", title: "Choose Translation Engine")
                ]
            ),
            MenuSection(
                title: "Personal Info & Privacy",
                icon: "gearshape",
                isExpanded: false,
                items: [
                    MenuItem(icon: "person", title: "Personal Info"),
                    MenuItem(icon: "lock", title: "Change Password"),
                    MenuItem(icon: "trash", title: "Delete Account")
                ]
            )
        ]
        
        // Initialize standalone items
        self.standaloneItems = [
            MenuItem(icon: "person", title: "Invite Your Friends"),
            MenuItem(icon: "star", title: "Rate Us"),
            MenuItem(icon: "arrow.left.circle", title: "Logout", showChevron: true) {
                print("Logout tapped")
            }
        ]
    }
    
    func toggleSection(_ sectionIndex: Int) {
        sections[sectionIndex].isExpanded.toggle()
    }
    
    func handleItemTap(title: String) {
        print("Tapped on: \(title)")
        // Add specific actions based on which item was tapped
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
        }
    }
}

struct LexiBotCard: View {
    var body: some View {
        HStack {
            Image(systemName: "waveform.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
            
            Text("Lexi Bot")
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
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
                        .frame(width: 22, height: 22)
                        .foregroundColor(.blue)
                    
                    Text(section.title)
                        .font(.headline)
                    
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
                    .frame(width: 22, height: 22)
                    .foregroundColor(.blue)
                
                Text(item.title)
                    .font(.body)
                
                Spacer()
                
                if item.showChevron {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
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
