import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()

            Button(action: {
                try? Auth.auth().signOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.red)
                    .bold()
            }

            Spacer()
        }
        .padding()
    }
}
