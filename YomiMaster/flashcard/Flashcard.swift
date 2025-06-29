import Foundation

struct Flashcard: Identifiable, Codable {
    var id: UUID
    var japaneseWord: String
    var meaning: String
    var exampleSentence: String
    var pronunciation: String

    // New fields for scheduling
    var reviewsSoFar: Int
    var lastInterval: Double
    var nextReviewDate: Date = Date.distantFuture

    init(
        id: UUID = UUID(),
        japaneseWord: String,
        meaning: String,
        exampleSentence: String = "",
        pronunciation: String = "",
        reviewsSoFar: Int = 0,
        lastInterval: Double = 0,
        nextReviewDate: Date = Date.distantFuture
    ) {
        self.id = id
        self.japaneseWord = japaneseWord
        self.meaning = meaning
        self.exampleSentence = exampleSentence
        self.pronunciation = pronunciation
        self.reviewsSoFar = reviewsSoFar
        self.lastInterval = lastInterval
        self.nextReviewDate = nextReviewDate
    }

    init(japaneseWord: String, meaning: String) {
        self.init(
            japaneseWord: japaneseWord,
            meaning: meaning,
            exampleSentence: "",
            pronunciation: "",
            reviewsSoFar: 0,
            lastInterval: 0,
            nextReviewDate: Date.distantFuture
        )
    }
}


class FlashcardManager: ObservableObject {
    static let shared = FlashcardManager()

    @Published var decks: [String: [Flashcard]] = [:]

    private init() {
        loadFlashcards()
    }

    func addFlashcard(word: String, meaning: String, toDeck deckName: String) {
        let newCard = Flashcard(japaneseWord: word, meaning: meaning)

        if decks[deckName] == nil {
            decks[deckName] = []
        }

        // Avoid duplicates (optional)
        if !decks[deckName]!.contains(where: { $0.japaneseWord == word }) {
            decks[deckName]?.append(newCard)
            saveFlashcards()
        }
    }

    func saveFlashcards() {
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: "flashcardDecks")
        }
    }

    func loadFlashcards() {
        if let saved = UserDefaults.standard.data(forKey: "flashcardDecks"),
           let decoded = try? JSONDecoder().decode([String: [Flashcard]].self, from: saved) {
            decks = decoded
        }
    }
}
