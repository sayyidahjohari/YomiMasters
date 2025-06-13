import SwiftUI

struct BookReaderViews: View {
    @StateObject var viewModel = BookReaderViewModel()
    @State private var highlightedWords: Set<String> = []
    @State private var selectedText: String = ""
    @State private var showDefinition: Bool = false
    @State private var definitionDetails: WordDetails? = nil
    @State private var showFurigana: Bool = false
    @State private var showPopupMenu: Bool = false
    @State private var bookmarkedPages: [Int] = []

    var body: some View {
        VStack {
            Spacer().frame(height: 60.0)

            // TabView for pages
            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(0..<viewModel.pages.count, id: \.self) { index in
                    PageContentView(
                        content: viewModel.pages[index].content,
                        highlightedWords: $highlightedWords,
                        showFurigana: $showFurigana,
                        onWordTap: handleWordTap,
                        onSentenceSelect: handleSentenceSelect
                    )
                    .padding()
                    .contextMenu {
                        Button(bookmarkedPages.contains(index) ? "Remove Bookmark" : "Bookmark") {
                            toggleBookmark(for: index)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            Spacer()

            // Page number at the bottom
            Text("Page \(viewModel.currentPageIndex + 1) of \(viewModel.pages.count)")
                .font(.subheadline)
                .padding(.bottom, 20)

            HStack {
                Spacer()
                // Popup Menu Button
                Button(action: {
                    showPopupMenu.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title)
                        .padding()
                }
                .popover(isPresented: $showPopupMenu) {
                    PopupMenuView(
                        showFurigana: $showFurigana,
                        bookmarkedPages: $bookmarkedPages,
                        highlightedWords: $highlightedWords,
                        pages: viewModel.pages.map { $0.content }
                    )
                }
            }
            .padding(.trailing, 20.0)
        }
        .onAppear {
            viewModel.loadBook(named: "uoto_hakucho") // Change this to your book's name
        }
        .sheet(isPresented: $showDefinition) {
            if let details = definitionDetails {
                DefinitionPopupView(
                    selectedWord: details.word,
                    sentenceContext: details.context,
                    meaning: details.meaning,
                    furigana: details.furigana,
                    grammarExplanation: details.grammarExplanation,
                    exampleUsage: details.exampleUsage,
                    showPopup: $showDefinition
                )
            } else {
                Text("Loading...")
                    .padding()
            }
        }
    }

    private func handleWordTap(_ word: String) {
        selectedText = word
        fetchDefinition(for: word)
    }

    private func handleSentenceSelect(_ sentence: String) {
        selectedText = sentence
        fetchDefinition(for: sentence)
    }

    private func fetchDefinition(for text: String) {
        showDefinition = true

        // Simulated word details (replace with API or dictionary lookup logic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            definitionDetails = WordDetails(
                word: text,
                meaning: "Sample meaning for '\(text)'",
                furigana: "ふりがな (Example)",
                grammarExplanation: "'\(text)' grammar explanation here.",
                context: "Context for '\(text)' in this sentence.",
                exampleUsage: "Example: \(text) を使った例文。"
            )
        }
    }

    private func toggleBookmark(for page: Int) {
        if let index = bookmarkedPages.firstIndex(of: page) {
            bookmarkedPages.remove(at: index)
        } else {
            bookmarkedPages.append(page)
        }
    }
}

#Preview{
    BookReaderViews()
}
