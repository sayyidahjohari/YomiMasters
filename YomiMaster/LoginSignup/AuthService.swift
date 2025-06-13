import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var role: String?
    @Published var isLoggedIn: Bool = false  // 👈 Add this

    private var db = Firestore.firestore()

    init() {
        self.user = Auth.auth().currentUser
        self.isLoggedIn = self.user != nil  // 👈 Set on init
        fetchUserRole()

        // 👇 Automatically update when auth state changes (e.g. auto-login or sign out from another device)
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
                self.isLoggedIn = user != nil
                if user != nil {
                    self.fetchUserRole()
                } else {
                    self.role = nil
                }
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let user = result?.user {
                // Reload the user to get the latest verification status
                user.reload { error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    if user.isEmailVerified {
                        DispatchQueue.main.async {
                            self.user = user
                            self.isLoggedIn = true
                            self.fetchUserRole()
                        }
                        completion(nil)
                    } else {
                        // Sign out unverified user
                        try? Auth.auth().signOut()
                        let notVerifiedError = NSError(
                            domain: "",
                            code: 401,
                            userInfo: [NSLocalizedDescriptionKey: "Email not verified. Please check your inbox."]
                        )
                        completion(notVerifiedError)
                    }
                }
            }
        }
    }

    func signUp(name: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let user = result?.user {
                // Save user info (name, email) in Firestore
                let userData: [String: Any] = [
                    "name": name,
                    "email": email,
                    "role": "user"  // or default role
                ]

                Firestore.firestore().collection("users").document(user.uid).setData(userData) { firestoreError in
                    if let firestoreError = firestoreError {
                        completion(firestoreError)
                        return
                    }

                    // Send verification email after saving data
                    user.sendEmailVerification { sendError in
                        if let sendError = sendError {
                            completion(sendError)
                        } else {
                            DispatchQueue.main.async {
                                self.user = nil
                                self.isLoggedIn = false
                            }
                            completion(nil)
                        }
                    }
                }
            }
        }
    }


    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.role = nil
                self.isLoggedIn = false  // 👈 This triggers UI change
            }
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }

    func fetchUserRole() {
        guard let uid = user?.uid else {
            print("No user logged in yet")
            return
        }
        print("Fetching role for uid:", uid)
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching role:", error.localizedDescription)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                print("User document does not exist!")
                return
            }
            if let data = snapshot.data(), let fetchedRole = data["role"] as? String {
                print("Fetched role:", fetchedRole)
                DispatchQueue.main.async {
                    self.role = fetchedRole
                }
            } else {
                print("Role field missing or not string")
            }
        }
    }
   



    func saveUserRole(role: String) {
        guard let uid = user?.uid, let email = user?.email else { return }
        db.collection("users").document(uid).setData([
            "email": email,
            "role": role
        ]) { error in
            if let error = error {
                print("Error saving user role: \(error.localizedDescription)")
            } else {
                print("User role saved successfully")
            }
        }
    }
}
