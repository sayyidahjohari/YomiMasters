import SwiftUI

struct RecentReadsView: View {
    // User Data
    @StateObject private var viewModel = HomepageViewModel()
    @Binding var isNavBarVisible: Bool  // Accept the binding
    @State private var showPopup: Bool = false

    let books: [Book]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Continue Reading")
                .font(.title2)
                .fontWeight(.heavy)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(books) { book in
                        NavigationLink(destination: NavbarReaderView(isNavBarVisible: $isNavBarVisible, showPopup: $showPopup)) {
                            VStack {
                                Image(book.cover)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                Text(book.title)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                GradientProgressView(progress: book.progress) // Use the custom gradient progress view
                                    .padding(.horizontal, 10)
                                Text("Page \(book.currentPage) of \(book.totalPages)")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                            .frame(width: 160)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct GradientProgressView: View {
    var progress: Double
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple]),
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack(alignment: .leading) {
            // Background bar with opacity
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.3)) // Set background opacity
                .frame(height: 10)

            // Gradient progress with opacity
            RoundedRectangle(cornerRadius: 5)
                .fill(gradient)
                .frame(width: CGFloat(progress) * 150, height: 10) // Width based on progress
                .opacity(0.4) // Set progress opacity (can adjust value from 0 to 1)
        }
        .frame(height: 10)
    }
}
