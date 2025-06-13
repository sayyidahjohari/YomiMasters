import SwiftUI

struct FlashcardListView: View {
    var deckName: String
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel

    var body: some View {
        let flashcards = flashcardViewModel.getFlashcards(forDeck: deckName) ?? []

        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("warmBeige").opacity(0.9),
                    Color("dustyRose").opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            List {
                // Review Start Button
                NavigationLink(destination: FlashcardView(flashcards: flashcards, deckName: deckName)) {
                    VStack(alignment: .leading) {
                        Text("Start Deck Review")
                            .font(.headline)
                        Text("Total Cards: \(flashcards.count)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }

                // Flashcard Rows
                ForEach(flashcards) { card in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.japaneseWord)
                            .font(.headline)
                        Text("Meaning: \(card.meaning)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if !card.pronunciation.isEmpty {
                            Text("Pronunciation: \(card.pronunciation)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        if !card.exampleSentence.isEmpty {
                            Text("Example: \(card.exampleSentence)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .onDelete { indexSet in
                    flashcardViewModel.removeFlashcard(at: indexSet, fromDeck: deckName)
                }
            }
            .background(Color.clear)
        }
        .navigationTitle(deckName)
        .toolbar {
            EditButton()
        }
    }
}

struct FlashcardListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FlashcardListView(deckName: "Sample Deck")
                .environmentObject(MockFlashcardViewModel())
        }
    }
}

class MockFlashcardViewModel: FlashcardViewModel {
    override func getFlashcards(forDeck deckName: String) -> [Flashcard]? {
        return [
            Flashcard(
                japaneseWord: "猫",
                meaning: "Cat",
                exampleSentence: "猫が寝ています。",
                pronunciation: "ねこ",
                reviewsSoFar: 2,
                lastInterval: 3.0
            ),
            Flashcard(
                japaneseWord: "犬",
                meaning: "Dog",
                exampleSentence: "犬は元気です。",
                pronunciation: "いぬ",
                reviewsSoFar: 1,
                lastInterval: 1.0
            )
        ]
    }
}
