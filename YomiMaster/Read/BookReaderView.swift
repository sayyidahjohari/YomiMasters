import SwiftUI

struct BookReaderView: View {
    @State private var isNavBarVisible = true
    @StateObject var viewModel = BookReaderViewModel()
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @State private var highlightedWords: Set<HighlightedWord> = []
    @State private var selectedText: String = ""
    @Binding var showDefinition: Bool
    @State private var definitionDetails: WordDetails? = nil
    @State private var showFurigana: Bool = false
    @State private var showPopupMenu: Bool = false
    @State private var bookmarkedPages: Set<Int> = []
    @State private var deckName = "Default Deck"
    @State private var jishoMeaning: String = ""

    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 60.0)

                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        PageContentView(
                            content: viewModel.pages[index].content,
                            currentPage: index,
                            highlightedWords: $highlightedWords,
                            showFurigana: $showFurigana,
                            onWordTap: handleWordTap,
                            onSentenceSelect: handleSentenceSelect
                        )
                        .padding()
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                Text("Page \(viewModel.currentPageIndex + 1) of \(viewModel.pages.count)")
                    .font(.subheadline)
                    .padding(.bottom, 20)

                HStack {
                    Spacer()
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
                            pages: viewModel.pages.map { $0.content },
                            currentPageIndex: viewModel.currentPageIndex
                        )
                    }
                }
                .padding(.trailing, 20.0)
            }

            // Overlay Popup
            if showDefinition, let details = definitionDetails {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDefinition = false
                    }

                //DefinitionPopupView(
                  //  selectedWord: details.word,
                    //jishoMeaning: jishoMeaning, //microsoftMeaning: details.meaningjishoMeaning: jishoMeaning, microsoftMeaning: details.meaning,
                    //showPopup: $showDefinition,
                   // deckName: deckName
               // )

               // .environmentObject(flashcardViewModel)
                //.padding()
                //./background(Color.white)
                //.cornerRadius(20)
                //.shadow(radius: 10)
                //.frame(maxWidth: 350)
                //.zIndex(10)
                //.transition(.scale)
            }
        }
        .onAppear {
            viewModel.loadBook(named: "uoto_hakucho")
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
}
struct BookReaderView_Previews: PreviewProvider {
    @State static var showDefinition = false

    static var previews: some View {
        // Create mock or sample environment objects
        let flashcardVM = FlashcardViewModel()

        // Provide BookReaderView with binding and environment objects
        BookReaderView(showDefinition: $showDefinition)
            .environmentObject(flashcardVM)
    }
}
