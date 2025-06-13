import Foundation
import CoreML
import FirebaseAuth
import FirebaseFirestore

class FlashcardViewModel: ObservableObject {
    static let shared = FlashcardViewModel()
    @Published var decks: [String: [Flashcard]] = [:]

    private var fileName: String? {
        guard let userId = userId else { return nil }
        return "\(userId)_flashcards.json"
    }

    private var model: FlashcardReviewScheduler? = {
        return try? FlashcardReviewScheduler(configuration: MLModelConfiguration())
    }()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    private var db = Firestore.firestore()

    func addFlashcard(word: String, meaning: String, toDeck deckName: String) {
        let newCard = Flashcard(japaneseWord: word, meaning: meaning)

        if decks[deckName] == nil {
            decks[deckName] = []
        }

        decks[deckName]?.append(newCard)
        saveFlashcards()
    }

    func removeFlashcard(at indexSet: IndexSet, fromDeck deckName: String) {
        decks[deckName]?.remove(atOffsets: indexSet)
        saveFlashcards()
    }

    func saveFlashcards() {
        guard let fileName = fileName else {
            print("❌ Cannot save, no user ID.")
            return
        }

        let deckData = decks.map { Deck(name: $0.key, flashcards: $0.value) }
        FileStorageManager.shared.save(deckData, to: fileName, userId: userId)
    }

    func loadFlashcards() {
        guard let userId = userId, let fileName = fileName else {
            print("❌ No user ID. Cannot load flashcards.")
            return
        }

        if let loadedDecks: [Deck] = FileStorageManager.shared.load(fileName, as: [Deck].self, userId: userId) {
            print("📥 Loaded decks for user \(userId)")
            for deck in loadedDecks {
                decks[deck.name] = deck.flashcards
            }
        } else if let sampleDecks: [Deck] = FileStorageManager.shared.load("sample_flashcards.json", as: [Deck].self) {
            print("⚠️ No user data, loaded sample decks instead")
            for deck in sampleDecks {
                decks[deck.name] = deck.flashcards
            }
            FileStorageManager.shared.save(sampleDecks, to: fileName, userId: userId)
        } else {
            print("⚠️ No flashcard data found at all")
            decks = [:]
        }
    }

    func getFlashcards(forDeck deckName: String) -> [Flashcard]? {
        return decks[deckName]
    }

    func addDeck(name: String) {
        if decks[name] == nil {
            decks[name] = []
            saveFlashcards()
        }
    }

    func deleteDeck(named name: String) {
        decks.removeValue(forKey: name)
        saveFlashcards()
    }

    func getDueFlashcards(forDeck deckName: String) -> [Flashcard] {
        let now = Date()
        return decks[deckName]?.filter { $0.nextReviewDate <= now } ?? []
    }

    // Unified updateFlashcardReview method with Firestore saving
    func updateFlashcardReview(deckName: String, flashcard: Flashcard, difficultyLabel: String) {
        guard let index = decks[deckName]?.firstIndex(where: { $0.id == flashcard.id }) else { return }

        var card = flashcard
        card.reviewsSoFar += 1

        let difficultyInt: Double
        switch difficultyLabel {
        case "Easy": difficultyInt = 1
        case "Good": difficultyInt = 2
        case "Hard": difficultyInt = 3
        case "Again": difficultyInt = 4
        default: difficultyInt = 2
        }

        if let prediction = try? model?.prediction(
            reviews_so_far: Double(card.reviewsSoFar),
            difficulty: difficultyInt,
            last_interval: card.lastInterval
        ) {
            let predictedInterval = prediction.next_session_interval
            card.lastInterval = predictedInterval

            if difficultyLabel == "Hard" || difficultyLabel == "Again" {
                card.nextReviewDate = Date()
            } else {
                card.nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(predictedInterval.rounded()), to: Date()) ?? Date()
            }
        }

        decks[deckName]?[index] = card
        saveFlashcards()
        
        // Save the review info to Firestore
        saveReviewToFirestore(deckName: deckName, flashcard: card, difficultyLabel: difficultyLabel)
    }

    // Firestore saving helper
    func saveReviewToFirestore(deckName: String, flashcard: Flashcard, difficultyLabel: String) {
        guard let userId = userId else {
            print("❌ No user logged in, cannot save review")
            return
        }

        let docRef = db.collection("users")
            .document(userId)
            .collection("decks")
            .document(deckName)
            .collection("flashcards")
            .document(flashcard.id.uuidString)

        let data: [String: Any] = [
            "japaneseWord": flashcard.japaneseWord,
            "meaning": flashcard.meaning,
            "reviewsSoFar": flashcard.reviewsSoFar,
            "lastInterval": flashcard.lastInterval,
            "nextReviewDate": Timestamp(date: flashcard.nextReviewDate),
            "difficulty": difficultyLabel,
            "reviewedAt": Timestamp(date: Date())
        ]

        docRef.setData(data, merge: true) { error in
            if let error = error {
                print("❌ Failed to save review data: \(error.localizedDescription)")
            } else {
                print("✅ Review saved to Firestore")
            }
        }
    }

    func generateAndSaveSampleFlashcards() {
        guard let url = Bundle.main.url(forResource: "sample_flashcards", withExtension: "json") else {
            print("❌ Failed to find sample_flashcards.json in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let flashcards = try JSONDecoder().decode([Flashcard].self, from: data)
            print("✅ Loaded \(flashcards.count) sample flashcards")

            decks["Sample Deck"] = flashcards
            saveFlashcards()
        } catch {
            print("❌ Error loading sample flashcards: \(error)")
        }
    }

    func renameDeck(oldName: String, newName: String) {
        if let cards = decks.removeValue(forKey: oldName) {
            decks[newName] = cards
            saveFlashcards()
        }
    }
}

// Model for each Deck
struct Deck: Codable, Identifiable {
    var id = UUID()
    var name: String
    var newCards: Int
    var learningCards: Int
    var dueCards: Int
    var flashcards: [Flashcard]

    init(name: String, newCards: Int = 0, learningCards: Int = 0, dueCards: Int = 0, flashcards: [Flashcard] = []) {
        self.name = name
        self.newCards = newCards
        self.learningCards = learningCards
        self.dueCards = dueCards
        self.flashcards = flashcards
    }
}
