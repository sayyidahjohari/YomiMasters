import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

// Make sure you call FirebaseApp.configure() in your @main App struct like:
// @main
// struct YomiMasterApp: App {
//   init() { FirebaseApp.configure() }
//   var body: some Scene { WindowGroup { AllBooksView() } }
// }

struct Bookfb: Identifiable {
    var id: String
    var title: String
    var filename: String
    var level: String
    var tags: [String]
    var genre: String
    var coverImageUrl: String?
    var description: String
}

class BooksViewModel: ObservableObject {
    @Published var booksByLevel: [String: [Bookfb]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    func fetchBooks() {
        print("Starting fetchBooks()")
        isLoading = true
        errorMessage = nil
        
        db.collection("books").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Firestore error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in Firestore 'books' collection")
                DispatchQueue.main.async {
                    self.errorMessage = "No books found"
                }
                return
            }
            
            print("Documents fetched:", documents.count)
            var grouped: [String: [Bookfb]] = [:]
            
            for doc in documents {
                let data = doc.data()
                print("Document data:", data)
                
                let book = Bookfb(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "No Title",
                    filename: data["filename"] as? String ?? "",
                    level: data["level"] as? String ?? "Unknown",
                    tags: data["tags"] as? [String] ?? [],
                    genre: data["genre"] as? String ?? "",
                    coverImageUrl: data["coverImageUrl"] as? String,
                    description: data["description"] as? String ?? ""
                )
                
                grouped[book.level, default: []].append(book)
            }
            
            DispatchQueue.main.async {
                self.booksByLevel = grouped
                print("Books grouped by level:", self.booksByLevel.keys.sorted())
            }
        }
    }
}

struct Pages: Identifiable {//
    let id = UUID()
    let content: String
}

class BookContentViewModel: ObservableObject {
    @Published var pages: [Pages] = []
    @Published var isLoading = false
    
    func fetchBookContent(filename: String) {
        isLoading = true
        let storage = Storage.storage()
        let fileRef = storage.reference().child("books/\(filename)")
        
        fileRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let data = data, let contentString = String(data: data, encoding: .utf8) {
                let rawPages = contentString.components(separatedBy: "-----------------------")
                let trimmedPages = rawPages
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                DispatchQueue.main.async {
                    self.pages = trimmedPages.map { Pages(content: $0) }
                }
            } else {
                print("Failed to fetch book content:", error?.localizedDescription ?? "Unknown error")
                DispatchQueue.main.async {
                    self.pages = [Pages(content: "Failed to load book content.")]
                }
            }
        }
    }
}

    struct AllBooksView: View {
        @StateObject private var viewModel = BooksViewModel()
       // @StateObject private var flashcardViewModel = FlashcardViewModel()

        var body: some View {
            NavigationStack {
                ZStack {
                    Color(red: 0.96, green: 0.94, blue: 0.88)
                        .ignoresSafeArea()


                    VStack(alignment: .leading, spacing: 0) {
                        // Sticky "Library" title
                        Text("Library")
                            .font(.system(size: 34, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .background(Color.clear)

                        if viewModel.isLoading {
                            ProgressView("Loading books...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let error = viewModel.errorMessage {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 24) {
                                    ForEach(["N5", "N4", "N3", "N2", "N1"], id: \.self) { level in
                                        if let books = viewModel.booksByLevel[level], !books.isEmpty {
                                            VStack(alignment: .leading, spacing: 12) {
                                                Text("Level \(level)")
                                                    .font(.title2)
                                                    .bold()
                                                    .padding(.horizontal)

                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 20) {
                                                        ForEach(books) { book in
                                                            NavigationLink(destination: BookContentView(filename: book.filename)) {
                                                                VStack(spacing: 8) {
                                                                    AsyncImage(url: URL(string: book.coverImageUrl ?? "")) { phase in
                                                                        if let image = phase.image {
                                                                            image
                                                                                .resizable()
                                                                                .scaledToFill()
                                                                        } else {
                                                                            Image("book")
                                                                                .resizable()
                                                                                .scaledToFill()
                                                                        }
                                                                    }
                                                                    .frame(width: 140, height: 200)
                                                                    .cornerRadius(12)
                                                                    .clipped()

                                                                    Text(book.title)
                                                                        .font(.system(size: 14, weight: .medium))
                                                                        .foregroundColor(.primary)
                                                                        .multilineTextAlignment(.center)
                                                                        .lineLimit(2)
                                                                        .frame(height: 40)
                                                                        .frame(maxWidth: .infinity)
                                                                }
                                                                .padding()
                                                                .frame(width: 160, height: 280) // Ensures all book cards are same size
                                                                .background(Color.white)
                                                                .cornerRadius(16)
                                                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                                                            }
                                                            .buttonStyle(PlainButtonStyle())
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)

                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 30)
                            }
                        }
                    }
                }
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .background(Color(red: 0.98, green: 0.95, blue: 0.90))
            .onAppear {
                viewModel.fetchBooks()
            }
        }
    }





struct BookContentView: View {
    let filename: String
    @StateObject private var viewModel = BookContentViewModel()
    
    @State private var clearSelectionTrigger = false
    @State private var popupPosition = CGPoint.zero
    @State private var highlightedWords = Set<HighlightedWord>()
    @State private var currentPage = 0
    @State private var selectedWord: String? = nil
    @State private var showMiniPopup = false
    @State private var showDefinitionPopup = false
    @State private var translatedText: String = ""
//
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                SelectableTextView(
                    text: currentPage < viewModel.pages.count ? viewModel.pages[currentPage].content : "",
                    fontSize: 18,
                    textColor: UIColor.label,
                    isEditable: false,
                    onSelection: { selected in
                        let trimmed = selected.trimmingCharacters(in: .whitespacesAndNewlines)
                        selectedWord = trimmed
                        showMiniPopup = !trimmed.isEmpty
                    },
                    clearSelectionTrigger: $clearSelectionTrigger,
                    popupPosition: $popupPosition,
                    highlightedWords: $highlightedWords,
                    currentPage: currentPage
                )
                .frame(minHeight: 400)
                .padding()
            }

            if showMiniPopup, let word = selectedWord {
                MiniActionPopupView(
                    word: word,
                    onTranslate: {
                        translateWithMicrosoft(text: word) { result in
                            DispatchQueue.main.async {
                                self.translatedText = result ?? "Translation failed"
                                self.showMiniPopup = false
                                self.showDefinitionPopup = true
                            }
                        }
                    },
                    onHighlight: {
                        highlightedWords.insert(HighlightedWord(word: word, page: currentPage, indexInPage: 0))
                        showMiniPopup = false
                    },
                    onAddToFlashcard: {
                        print("Add to flashcard: \(word)")
                        showMiniPopup = false
                    }
                )
                .position(popupPosition)
            }

            if showDefinitionPopup, let word = selectedWord {
                DefinitionPopupView(
                    selectedWord: word,
                    sentenceContext: "Example sentence using '\(word)'",
                    meaning: translatedText,
                    furigana: "ふりがな",
                    grammarExplanation: "Some grammar point",
                    exampleUsage: "Example usage of the word",
                    showPopup: $showDefinitionPopup,
                    deckName: filename.replacingOccurrences(of: ".txt", with: "")
                )
                .background(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationTitle(filename.replacingOccurrences(of: ".txt", with: "").capitalized)
        .onAppear {
            viewModel.fetchBookContent(filename: filename)
        }
    }
}

struct MiniActionPopupView: View {
    let word: String
    let onTranslate: () -> Void
    let onHighlight: () -> Void
    let onAddToFlashcard: () -> Void

    var body: some View {
        HStack {
            Button("Translate", action: onTranslate)
            Button(action: onHighlight) {
                Label("Highlight", systemImage: "highlighter")
            }
            Button(action: onAddToFlashcard) {
                Label("Add", systemImage: "plus.square.on.square")
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}


// Preview Provider
struct FirebaseBooksTestView_Previews: PreviewProvider {
    static var previews: some View {
        AllBooksView()
    }
}
