import SwiftUI
import FirebaseAuth

struct LoginSignupView: View {
    @EnvironmentObject var authService: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var name = ""  // <-- Added this state

    @State private var error: String?
    @State private var showEmailSentAlert = false
    @State private var showResendButton = false
    @State private var showForgotPasswordSheet = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.94, blue: 0.88)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text(isLogin ? "Login" : "Sign Up")
                    .font(.largeTitle).bold()

                if !isLogin {  // <-- Show name field only on Sign Up
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                }

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }

                Button(action: handleAuth) {
                    Text(isLogin ? "Login" : "Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient.dustyRose2gradient)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)

                if showResendButton {
                    Button("Resend Verification Email") {
                        resendVerificationEmail()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }

                if isLogin {
                    Button("Forgot Password?") {
                        showForgotPasswordSheet = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }

                Button(action: {
                    isLogin.toggle()
                    resetFields()
                }) {
                    Text(isLogin ? "Don't have an account? Sign up" : "Already have an account? Login")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .alert("Verification Email Sent", isPresented: $showEmailSentAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please check your inbox and verify your email before logging in.")
            }
            .sheet(isPresented: $showForgotPasswordSheet) {
                ForgotPasswordView(email: $email)
            }
        }
    }

    // LoginSignupView.swift

    func handleAuth() {
        error = nil
        showResendButton = false
        isLoading = true

        if isLogin {
            authService.login(email: email, password: password) { err in
                DispatchQueue.main.async {
                    isLoading = false
                    if let err = err {
                        self.error = err.localizedDescription
                        if err.localizedDescription.contains("Email not verified") {
                            showResendButton = true
                        }
                    } else {
                        FlashcardViewModel.shared.loadFlashcards()
                    }
                }
            }
        } else {
            // Validate that name is not empty when signing up
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                self.error = "Please enter your name."
                self.isLoading = false
                return
            }

            authService.signUp(name: name, email: email, password: password) { err in
                DispatchQueue.main.async {
                    isLoading = false
                    if let err = err {
                        self.error = err.localizedDescription
                    } else {
                        // No need to update displayName here because already saved in Firestore

                        showEmailSentAlert = true
                        showResendButton = true
                    }
                }
            }
        }
    }


    func resendVerificationEmail() {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { err in
                if let err = err {
                    self.error = "Failed to resend: \(err.localizedDescription)"
                } else {
                    self.error = nil
                    self.showEmailSentAlert = true
                }
            }
        } else {
            self.error = "User not found. Please login first."
        }
    }

    func resetFields() {
        error = nil
        showResendButton = false
        isLoading = false
        name = ""    // Reset name field when toggling login/signup
        email = ""
        password = ""
    }
}

struct ForgotPasswordView: View {
    @Binding var email: String
    @Environment(\.dismiss) var dismiss

    @State private var message: String?
    @State private var isSending = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Enter your email to reset password")
                    .font(.headline)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)

                if let message = message {
                    Text(message)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }

                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }

                Button("Send Reset Email") {
                    sendPasswordReset()
                }
                .disabled(email.isEmpty || isSending)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient.dustyRose2gradient)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
                .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .navigationTitle("Forgot Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    func sendPasswordReset() {
        isSending = true
        message = nil

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                isSending = false
                if let error = error {
                    message = "Failed: \(error.localizedDescription)"
                } else {
                    message = "Password reset email sent. Please check your inbox."
                }
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignupView()
            .environmentObject(AuthService())
    }
}
