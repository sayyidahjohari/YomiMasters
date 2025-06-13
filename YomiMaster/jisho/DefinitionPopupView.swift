import SwiftUI

struct DefinitionPopupView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel

    let selectedWord: String
    let jishoMeaning: String
    let microsoftMeaning: String

    @Binding var showPopup: Bool
    let deckName: String

    var body: some View {
        VStack(spacing: 20) {
            Text(selectedWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .background(Color.softPink)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 15) {
                SectionTitle(title: "Jisho Meaning", color: .green)
                Text(jishoMeaning.isEmpty ? "No Jisho meaning" : jishoMeaning)

                SectionTitle(title: "Microsoft Translation", color: .blue)
                Text(microsoftMeaning.isEmpty ? "No Microsoft translation" : microsoftMeaning)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)

            Button("Add to Flashcard") {
                let combinedMeaning =
                    "Jisho meaning:\n\(jishoMeaning.isEmpty ? "No meaning" : jishoMeaning)\n\n" +
                    "Microsoft translation:\n\(microsoftMeaning.isEmpty ? "No translation" : microsoftMeaning)"

                flashcardViewModel.addFlashcard(
                    word: selectedWord,
                    meaning: combinedMeaning,
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
