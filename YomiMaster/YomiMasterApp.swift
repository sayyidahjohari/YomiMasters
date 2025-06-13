import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

@main
struct YomiMasterApp: App {
    @StateObject var authService = AuthService()
    @StateObject var flashcardViewModel = FlashcardViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .onAppear {
                                    // Force sign out if current user is invalid or missing
                                    if Auth.auth().currentUser == nil {
                                        try? Auth.auth().signOut()
                                    }
                                }
                .environmentObject(flashcardViewModel)
        }
    }
}
