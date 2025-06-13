import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if let user = authService.user {
                if authService.role == "admin" {
                    AdminPageView()
                } else if authService.role == "user" {
                    UserHomePageView()
                } else {
                    ProgressView("Loading...")
                }
            } else {
                LoginSignupView()
            }
        }
        .onAppear {
            authService.fetchUserRole()
        }
    }
}
