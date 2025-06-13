import SwiftUI

struct LoginPage: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    
    var body: some View {
        ZStack {
            Color("SoftBeige")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Yomi Master")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                    .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.gray)
                    HStack {
                        if isSecure {
                            SecureField("Enter your password", text: $password)
                        } else {
                            TextField("Enter your password", text: $password)
                        }
                        Button(action: { isSecure.toggle() }) {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    // Handle login logic here
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Button(action: {
                        // Navigate to Sign Up page
                    }) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.brown)
                    }
                }
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
