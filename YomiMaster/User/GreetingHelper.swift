import SwiftUI

struct GreetingHelper {
    static func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        case 18..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
}

struct GreetingView: View {
    let name: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Show: Good Night, s@m.com
            Text("\(GreetingHelper.getGreeting()), \(name ?? "Yomi")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            

            Text("Ready to learn today?")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 10)
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView(name: "s@m.com")
    }
}
