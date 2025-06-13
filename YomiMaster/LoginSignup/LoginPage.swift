import SwiftUI
import Firebase
import FirebaseAuth

struct LoginPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false

    var body: some View {
        if userIsLoggedIn {
            NavbarView()
        } else {
            content
                .onAppear {
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            userIsLoggedIn = true
                        }
                    }
                }
        }
    }

    // ✅ View content
    var content: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("soft pink").opacity(0.6),
                    Color.blue.opacity(0.1),
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Yomi Master")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                    .padding(.bottom, 40)

                VStack(alignment: .leading) {
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal, 30)

                VStack(alignment: .leading) {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                Button(action: {
                    register()
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)

                    Button(action: {
                        login()
                    }) {
                        Text("Log in")
                            .fontWeight(.bold)
                            .foregroundColor(.brown)
                    }
                }
            }
        }
    }

    // ✅ These should be declared outside of the `var content` body
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Registration error: \(error.localizedDescription)")
            }
        }
    }
}

    struct LoginPage_Previews: PreviewProvider {
        static var previews: some View {
            LoginPage()
        }
    }

