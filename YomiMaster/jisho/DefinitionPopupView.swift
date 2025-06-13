import SwiftUI

struct DefinitionPopupView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    let selectedWord: String
    let sentenceContext: String
    let meaning: String
    let furigana: String
    let grammarExplanation: String
    let exampleUsage: String
    @Binding var showPopup: Bool
    let deckName: String  // Add a deck name to specify where to save the flashcard

    var body: some View {
        VStack(spacing: 20) {
            Text(selectedWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .background(Color.softPink)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 15) {
                SectionTitle(title: "Meaning", color: .blue)
                Text(meaning)

                SectionTitle(title: "Context in Sentence", color: .purple)
                Text("The phrase \(selectedWord) means '\(meaning)' as part of the sentence '\(sentenceContext)'.")

                if !grammarExplanation.isEmpty {
                    SectionTitle(title: "Grammar", color: .green)
                    Text(grammarExplanation)
                }

                if !furigana.isEmpty {
                    SectionTitle(title: "Reading (Furigana)", color: .orange)
                    Text(furigana)
                }

                if !exampleUsage.isEmpty {
                    SectionTitle(title: "Example Usage", color: .red)
                    Text(exampleUsage)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)

            Button("Add to Flashcard") {
                flashcardViewModel.addFlashcard(
                    word: selectedWord,
                    meaning: meaning.isEmpty ? "Meaning not available" : meaning,
                    toDeck: deckName
                )
                showPopup = false
            }


            .padding()
            .background(Color.softPink)
            .cornerRadius(10)

                       Button("Close") {
                           showPopup = false
                       }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
    }
}
