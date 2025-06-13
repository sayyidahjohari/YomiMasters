import SwiftUI

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
                // --- Begin adjustment for popup position ---
                let popupWidth: CGFloat = 250
                let popupHeight: CGFloat = 50
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height

                var adjustedX = popupPosition.x
                var adjustedY = popupPosition.y

                // Prevent right overflow
                if adjustedX + popupWidth / 2 > screenWidth {
                    adjustedX = screenWidth - popupWidth / 2 - 10
                }
                // Prevent left overflow
                if adjustedX - popupWidth / 2 < 0 {
                    adjustedX = popupWidth / 2 + 10
                }
                // Prevent top overflow
                if adjustedY - popupHeight / 2 < 0 {
                    adjustedY = popupHeight / 2 + 10
                }
                // Prevent bottom overflow
                if adjustedY + popupHeight / 2 > screenHeight {
                    adjustedY = screenHeight - popupHeight / 2 - 10
                }
                // --- End adjustment ---

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
                .frame(width: popupWidth, height: popupHeight)
                .position(x: adjustedX, y: adjustedY)
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
