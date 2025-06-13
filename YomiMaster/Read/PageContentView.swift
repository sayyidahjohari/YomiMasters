import SwiftUI

struct PageContentView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    let content: String
    let currentPage: Int
    @Binding var highlightedWords: Set<HighlightedWord>
    @Binding var showFurigana: Bool
    let onWordTap: (String) -> Void
    let onSentenceSelect: (String) -> Void

    @State private var showPopupMenu = false
    @State private var showDefinitionPopup = false
    @State private var selectedWord = ""
    @State private var selectedSentence = ""
    @State private var meaning = ""
    @State private var furigana = ""
    @State private var grammarExplanation = ""
    @State private var exampleUsage = ""

    @State private var popupPosition = CGPoint(x: 0, y: 0)
    @State private var wordOccurrences: [String: Int] = [:]
    @State private var deckName = "Default Deck"  // Add a deckName property


    var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical) {
                    SelectableTextView(
                        text: content,
                        fontSize: 20,
                        onSelection: { selectedText in
                            selectedWord = selectedText
                            selectedSentence = selectedText
                            showPopupMenu = true
                        },
                        clearSelectionTrigger: $showPopupMenu,
                        popupPosition: $popupPosition,
                        highlightedWords: $highlightedWords,
                        currentPage: currentPage
                    )
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .multilineTextAlignment(.leading)
                    .padding()
                }

                if showPopupMenu {
                    VStack {
                        HStack {
                            Button("Lookup word") {
                                fetchWordData(for: selectedWord)
                                showDefinitionPopup = true
                                showPopupMenu = false
                            }
                            .padding()

                            Button("Highlight") {
                                let words = selectedWord.split(separator: " ").map(String.init)
                                for word in words {
                                    let index = (wordOccurrences[word] ?? 0) + 1
                                    wordOccurrences[word] = index
                                    let highlightedWord = HighlightedWord(word: word, page: currentPage, indexInPage: index)
                                    highlightedWords.insert(highlightedWord)
                                }
                                showPopupMenu = false
                            }
                            .padding()

                            Button("Remove Highlight") {
                                let words = selectedWord.split(separator: " ").map(String.init)
                                for word in words {
                                    highlightedWords = highlightedWords.filter {
                                        !($0.word == word && $0.page == currentPage)
                                    }
                                }
                                showPopupMenu = false
                            }
                            .padding()
                            .disabled(!isHighlighted(selectedWord))

                            Button("Translate") {
                                translateWithMicrosoft(text: selectedSentence) { translated in
                                    DispatchQueue.main.async {
                                        if let translated = translated {
                                            self.meaning = translated
                                        } else {
                                            self.meaning = "Translation failed."
                                        }
                                        self.showDefinitionPopup = true
                                    }
                                }
                                showPopupMenu = false
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                        .position(popupPosition)
                    }
                }

                if showFurigana {
                    Text(furigana)
                        .padding()
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .overlay(
                Group {
                    if showDefinitionPopup {
                        AnyView(
                            ZStack {
                                Color.black.opacity(0.4)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        showDefinitionPopup = false
                                    }

                                //DefinitionPopupView(
                                  //  selectedWord: selectedWord,
                                    //microsoftMeaning: meaning, // assuming this is translated text
                                    //showPopup: $showDefinitionPopup,
                                    //deckName: deckName
                                //)



                                //.frame(maxWidth: 400)
                                //.padding()
                                //.background(Color.white)
                                //.cornerRadius(20)
                                //.shadow(radius: 10)
                                //.transition(.scale)
                            }
                        )
                    } else {
                        AnyView(EmptyView())
                    }
                },
                alignment: .center
            )

        }
        .onTapGesture {
            if showPopupMenu {
                showPopupMenu = false
            }
        }
    }

    func fetchWordData(for word: String) {
        if word == "歩く" {
            meaning = "to walk"
            furigana = "あるく"
            grammarExplanation = "Verb in the present tense."
            exampleUsage = "私は公園で歩いています。"
        }
    }

    func isHighlighted(_ word: String) -> Bool {
        let words = word.split(separator: " ").map(String.init)
        return words.contains { w in
            highlightedWords.contains { $0.word == w && $0.page == currentPage }
        }
    }

    func getIndexForWord(_ word: String) -> Int {
        highlightedWords.first(where: { $0.word == word && $0.page == currentPage })?.indexInPage ?? 1
    }
}
