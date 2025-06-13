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
            } else {
                DispatchQueue.main.async {
                    self.user = result?.user
                    self.isLoggedIn = true
                    self.fetchUserRole()
                }
                completion(nil)
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                    self.isLoggedIn = true
                    self.saveUserRole(role: "user")
                    self.fetchUserRole()
                }
                completion(nil)
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
