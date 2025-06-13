import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var isSigningOut = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = authService.user {
                    Text("Email:")
                        .font(.headline)
                    Text(user.email ?? "Unknown")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Divider()

                    Text("Role:")
                        .font(.headline)
                    Text(authService.role ?? "N/A")
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("No user logged in")
                }

                Spacer()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(role: .destructive) {
                    Task {
                        await signOut()
                    }
                } label: {
                    Text(isSigningOut ? "Signing Out..." : "Sign Out")
                        .frame(maxWidth: .infinity)
                }
                .disabled(isSigningOut)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    func signOut() async {
        isSigningOut = true
        errorMessage = nil
        do {
            try await authService.signOut()
            dismiss() // close the profile sheet on success
        } catch {
            errorMessage = error.localizedDescription
        }
        isSigningOut = false
    }
}
