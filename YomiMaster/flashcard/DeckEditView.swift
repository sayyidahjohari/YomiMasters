import SwiftUI

struct DeckEditView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel

    let deckName: String

    @State private var editingFlashcard: Flashcard? = nil
    @State private var newWord: String = ""
    @State private var newMeaning: String = ""

    var body: some View {
        VStack {
            Text("Editing Deck: \(deckName)")
                .font(.title)
                .padding()

            List {
                ForEach(flashcardViewModel.decks[deckName] ?? []) { flashcard in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(flashcard.word)
                                .font(.headline)
                            Text(flashcard.meaning)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: {
                            editingFlashcard = flashcard
                            newWord = flashcard.word
                            newMeaning = flashcard.meaning
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }

                        Button(role: .destructive) {
                            if let index = flashcardViewModel.decks[deckName]?.firstIndex(of: flashcard) {
                                flashcardViewModel.decks[deckName]?.remove(at: index)
                                flashcardViewModel.saveFlashcards()
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .sheet(item: $editingFlashcard) { flashcard in
            VStack(spacing: 20) {
                Text("Edit Flashcard")
                    .font(.headline)

                TextField("Japanese Word", text: $newWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Meaning", text: $newMeaning)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    Button("Cancel") {
                        editingFlashcard = nil
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Save") {
                        guard !newWord.isEmpty, !newMeaning.isEmpty else { return }

                        if let index = flashcardViewModel.decks[deckName]?.firstIndex(where: { $0.id == flashcard.id }) {
                            flashcardViewModel.decks[deckName]?[index].word = newWord
                            flashcardViewModel.decks[deckName]?[index].meaning = newMeaning
                            flashcardViewModel.saveFlashcards()
                        }

                        editingFlashcard = nil
                    }
                }
                .padding(.top)
            }
            .padding()
        }
    }
}
