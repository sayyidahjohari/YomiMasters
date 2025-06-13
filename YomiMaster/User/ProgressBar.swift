import SwiftUI

struct ProgressBar: View {
    let title: String
    let currentValue: Int
    let totalValue: Int
    let progressGradient: LinearGradient
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(progressGradient)
                Text(title)
                    .font(.headline)
            }
            .padding(.bottom, 5)

            ZStack(alignment: .leading) { // Align the progress bar's gradient to the left
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3)) // Background track
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(progressGradient) // Gradient progress
                    .frame(width: progressWidth, height: 8) // Dynamically adjust width
                    .opacity(0.8)
            }
            .padding(.horizontal, 5)

            HStack {
                Text("\(currentValue) of \(totalValue)")
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("not so hot pink").opacity(0.2),
                    //Color("dark blue").opacity(0.5)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private var progress: Double {
        guard totalValue > 0 else { return 0.0 }
        return Double(currentValue) / Double(totalValue)
    }

    private var progressWidth: CGFloat {
        guard totalValue > 0 else { return 0.0 }
        return CGFloat(progress) * UIScreen.main.bounds.width * 0.8 // Adjust for screen width
    }
}



#Preview {
    ProgressBar(title: "Hello", currentValue: 10, totalValue: 100, progressGradient: LinearGradient(
        gradient: Gradient(colors: [.darkBlue, .notSoHotPink]),
        startPoint: .leading,
        endPoint: .trailing
    ),
    icon: "rectangle.stack.fill")
}
