import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var isSigningOut = false
    @State private var errorMessage: String?
    @State private var userName: String = "Yomi"  // default fallback

    // Fetch the user's name from Firestore
    func fetchUserName(uid: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String
                DispatchQueue.main.async {
                    userName = name ?? "Yomi"
                }
            } else {
                // Optional: handle error or missing doc here
                print("User document does not exist or error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Profile Icon & Welcome
                VStack(spacing: 40) {
                    // Profile Icon & Name
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue.opacity(0.8))
                            .shadow(radius: 8)

                        // Use local userName state variable
                        Text(userName)
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 40)
                }

                // User Info Cards
                VStack(spacing: 30) {
                    userInfoCard(title: "Email", value: authService.user?.email ?? "Unknown")
                    userInfoCard(title: "Role", value: authService.role ?? "N/A")
                }
                .padding(.horizontal, 30)

                Spacer()

                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Sign Out Button
                Button {
                    Task {
                        await signOut()
                    }
                } label: {
                    Text(isSigningOut ? "Signing Out..." : "Sign Out")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .disabled(isSigningOut)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .fontWeight(.semibold)
                    }
                }
            }
            // Fetch user name when view appears
            .task {
                if let uid = authService.user?.uid {
                    fetchUserName(uid: uid)
                }
            }
        }
    }

    // Reusable user info card style
    func userInfoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.blue)
            Text(value)
                .font(.title2.weight(.medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
        .shadow(color: Color.blue.opacity(0.2), radius: 6, x: 0, y: 4)
    }

    func signOut() async {
        isSigningOut = true
        errorMessage = nil
        do {
            try await authService.signOut()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSigningOut = false
    }
}
