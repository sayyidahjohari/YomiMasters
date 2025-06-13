import SwiftUI
import FirebaseAuth

// MARK: - Tab Enum
enum Tab {
    case home
    case flashcards
    case library
}

struct NavbarView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @EnvironmentObject var authService: AuthService
    
    @State private var selectedTab: Tab = .home
    @State private var isNavBarVisible: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomepageView(isNavBarVisible: $isNavBarVisible)
                        .environmentObject(authService)
                        .environmentObject(flashcardViewModel)
                    
                case .flashcards:
                    DeckListView()
                        .environmentObject(flashcardViewModel)
                    
                case .library:
                    AllBooksView()
                        .environmentObject(flashcardViewModel)
                }
            }
            
            if isNavBarVisible {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            TabBarButton(icon: "books.vertical.fill", tab: .library, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(icon: "house.fill", tab: .home, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(icon: "rectangle.stack.fill", tab: .flashcards, selectedTab: $selectedTab)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 30)
        .background(Color.warmBeige)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct TabBarButton: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Image(systemName: icon)
                .foregroundColor(selectedTab == tab ? .brown : .gray)
                .font(.system(size: 25, weight: .bold))
        }
    }
}

// MARK: - Preview
#Preview {
    NavbarView()
        .environmentObject(FlashcardViewModel())
        .environmentObject(AuthService())
}
