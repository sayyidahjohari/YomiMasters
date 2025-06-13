import SwiftUI

struct FlashcardListView: View {
    @Binding var deckName: String
    var onDeleteDeck: () -> Void
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @Environment(\.dismiss) var dismiss
    @State private var newDeckName: String = ""
    @State private var showRenameField = false

    var body: some View {
        let flashcards = flashcardViewModel.getFlashcards(forDeck: deckName) ?? []

        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.88)
                    .ignoresSafeArea()

                List {
                    Section(header: Text("Deck Info")) {
                        HStack {
                            if showRenameField {
                                TextField("New Deck Name", text: $newDeckName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Save") {
                                    renameDeck()
                                }
                                .disabled(newDeckName.isEmpty)
                            } else {
                                Text(deckName)
                                    .font(.headline)
                                Spacer()
                                Button("Rename") {
                                    showRenameField = true
                                    newDeckName = deckName
                                }
                            }
                        }

                        Button("Delete Deck", role: .destructive) {
                            onDeleteDeck()
                            dismiss()
                        }
                    }

                    Section(header: Text("Cards")) {
                        ForEach(flashcards) { card in
                            VStack(alignment: .leading) {
                                Text(card.japaneseWord)
                                    .font(.headline)
                                Text(card.meaning)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete { indexSet in
                            flashcardViewModel.removeFlashcard(at: indexSet, fromDeck: deckName)
                        }
                    }
                }
            }
            .navigationTitle("Edit Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    func renameDeck() {
        guard !newDeckName.isEmpty,
              newDeckName != deckName,
              flashcardViewModel.decks[newDeckName] == nil else { return }

        let cards = flashcardViewModel.decks.removeValue(forKey: deckName)
        flashcardViewModel.decks[newDeckName] = cards ?? []
        flashcardViewModel.saveFlashcards()
        deckName = newDeckName
        showRenameField = false
    }
}
