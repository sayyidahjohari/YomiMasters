import SwiftUI
import FirebaseStorage

class FirebaseBooksTestViewModel: ObservableObject {
    @Published var bookTitles: [String] = []
    private let storage = Storage.storage()

    func fetchBookTitles() {
        let booksRef = storage.reference().child("books")
        booksRef.listAll { result, error in
            if let error = error {
                print("Error listing books:", error.localizedDescription)
                return
            }
            var titles: [String] = []
            for item in result.items {
                let filename = item.name
                let title = filename.replacingOccurrences(of: ".txt", with: "")
                                    .replacingOccurrences(of: "_", with: " ")
                                    .capitalized
                titles.append(title)
            }
            DispatchQueue.main.async {
                self.bookTitles = titles
            }
        }
    }
}

struct FirebaseBooksTestView: View {
    @StateObject private var viewModel = FirebaseBooksTestViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.bookTitles, id: \.self) { title in
                Text(title)
            }
            .navigationTitle("Books from Firebase")
            .onAppear {
                viewModel.fetchBookTitles()
            }
        }
    }
}
