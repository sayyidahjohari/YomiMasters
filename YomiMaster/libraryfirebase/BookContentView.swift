import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct BookContentView: View {
    let filename: String
    @StateObject private var viewModel = BookContentViewModel()
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @State private var jishoMeaning: String = ""

    @State private var clearSelectionTrigger = false
    @State private var popupPosition = CGPoint.zero
    @State private var highlightedWords = Set<HighlightedWord>()
    @State private var currentPage = 0
    @State private var selectedWord: String? = nil
    @State private var showMiniPopup = false
    @State private var showDefinitionPopup = false
    @State private var translatedText: String = ""

    // Add font size state for adjustable font size
    @State private var fontSize: CGFloat = 18

    var body: some View {
        // Calculate popup position safely outside of the View builder
        let popupWidth: CGFloat = 250
        let popupHeight: CGFloat = 50
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // Adjust popup position to keep on screen
        var adjustedX = popupPosition.x
        var adjustedY = popupPosition.y

        if adjustedX + popupWidth / 2 > screenWidth {
            adjustedX = screenWidth - popupWidth / 2 - 10
        }
        if adjustedX - popupWidth / 2 < 0 {
            adjustedX = popupWidth / 2 + 10
        }
        if adjustedY - popupHeight / 2 < 0 {
            adjustedY = popupHeight / 2 + 10
        }
        if adjustedY + popupHeight / 2 > screenHeight {
            adjustedY = screenHeight - popupHeight / 2 - 10
        }

        return VStack(spacing: 10) {
            // Font size slider
            HStack {
                Text("Font Size: \(Int(fontSize))")
                Slider(value: $fontSize, in: 14...30, step: 1)
                    .accentColor(.blue)
            }
            .padding([.horizontal])

            ScrollView {
                SelectableTextView(
                    text: currentPage < viewModel.pages.count ? viewModel.pages[currentPage].content : "",
                    fontSize: fontSize,
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
                .multilineTextAlignment(.center)
            }
        }
        .overlay(miniPopup(adjustedX: adjustedX, adjustedY: adjustedY, popupWidth: popupWidth, popupHeight: popupHeight))
        .background(backgroundDismiss)
        .overlay(definitionPopup)
        .navigationTitle(filename.replacingOccurrences(of: ".txt", with: "").capitalized)
        .onAppear {
            viewModel.fetchBookContent(filename: filename)
        }
    }

    // MARK: - Computed Views

    private func miniPopup(adjustedX: CGFloat, adjustedY: CGFloat, popupWidth: CGFloat, popupHeight: CGFloat) -> some View {
        Group {
            if showMiniPopup, let word = selectedWord {
                MiniActionPopupView(
                    word: word,
                    onTranslate: { translateSelectedWord(word) },
                    onHighlight: {
                        highlightedWords.insert(HighlightedWord(word: word, page: currentPage, indexInPage: 0))
                        showMiniPopup = false
                    },
                    onAddToFlashcard: {
                      //  flashcardViewModel.addFlashcard(
                        //    word: word,
                          //  meaning: translatedText.isEmpty ? "No meaning" : translatedText,
                           // toDeck: filename.replacingOccurrences(of: ".txt", with: "")
                        //)
                       // showMiniPopup = false
                    }
                )
                .frame(width: popupWidth, height: popupHeight)
                .position(x: adjustedX, y: adjustedY)
            }
        }
    }

    private var backgroundDismiss: some View {
        Group {
            if showMiniPopup {
                Color.black.opacity(0.0001)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showMiniPopup = false
                    }
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }

    private var definitionPopup: some View {
        Group {
            if showDefinitionPopup, let word = selectedWord {
                DefinitionPopupView(
                    selectedWord: word,
                    jishoMeaning: jishoMeaning,
                    microsoftMeaning: translatedText,
                    showPopup: $showDefinitionPopup,
                    deckName: filename.replacingOccurrences(of: ".txt", with: "")
                )


                .background(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }

    // MARK: - Helper Methods

    private func translateSelectedWord(_ word: String) {
        translateWithMicrosoft(text: word) { microsoftResult in
            JishoAPIManager.shared.searchWord(word) { jishoResult in
                DispatchQueue.main.async {
                    let translated = microsoftResult ?? "Translation failed"
                    self.translatedText = translated
                    self.jishoMeaning = jishoResult?.senses.first?.english_definitions.joined(separator: ", ") ?? "Jisho definition not found"

                    // REMOVE this addFlashcard call here
                    // flashcardViewModel.addFlashcard(
                    //     word: word,
                    //     meaning: translated,
                    //     toDeck: filename.replacingOccurrences(of: ".txt", with: "")
                    // )

                    self.showMiniPopup = false
                    self.showDefinitionPopup = true
                }
            }
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
            //Button(action: onAddToFlashcard) {
              //  Label("Add", systemImage: "plus.square.on.square")
            //}
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
