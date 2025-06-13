import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if !authService.isLoggedIn {
                // Not logged in
                LoginSignupView()
            } else if let role = authService.role {
                // Logged in and role is fetched
                if role == "admin" {
                    AdminUploadView()
                } else {
                    NavbarView()
                }
            } else {
                // Role still loading
                ProgressView("Loading...")
            }
        }
        .onAppear {
            print("Rendering RootView - isLoggedIn: \(authService.isLoggedIn), user: \(authService.user?.email ?? "nil"), role: \(authService.role ?? "nil")")
        }
    }
}
