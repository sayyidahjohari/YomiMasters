import Foundation
import CoreML

class FlashcardViewModel: ObservableObject {
    @Published var decks: [String: [Flashcard]] = [:]
    private let fileName = "flashcards.json"

    private var model: FlashcardReviewScheduler? = {
        return try? FlashcardReviewScheduler(configuration: MLModelConfiguration())
    }()


    init() {
        loadFlashcards()
        
        // If no decks loaded, add a sample deck and cards for testing
        if decks.isEmpty {
            let sampleDeckName = "Sample Deck"
            let sampleCards = [
                Flashcard(japaneseWord: "歩く", meaning: "to walk"),
                Flashcard(japaneseWord: "食べる", meaning: "to eat"),
                Flashcard(japaneseWord: "読む", meaning: "to read")
            ]
            decks[sampleDeckName] = sampleCards
            
            saveFlashcards() // Save it immediately so it persists next runs
            print("📝 Sample deck created for testing.")
        }
    }


    // Adds a flashcard to a specific deck (identified by deckName)
    func addFlashcard(word: String, meaning: String, toDeck deckName: String) {
        let newCard = Flashcard(japaneseWord: word, meaning: meaning)
        
        if decks[deckName] == nil {
            decks[deckName] = [] // Create new deck if it doesn't exist
        }
        
        decks[deckName]?.append(newCard) // Add the new card to the specified deck
        saveFlashcards()
    }

    // Removes a flashcard from a specific deck by index
    func removeFlashcard(at indexSet: IndexSet, fromDeck deckName: String) {
        decks[deckName]?.remove(atOffsets: indexSet)
        saveFlashcards()
    }

    // Saves the flashcards data to disk
    func saveFlashcards() {
        // Convert dictionary to an array of deck objects to store
        let deckData = decks.map { (deckName, cards) in
            return Deck(name: deckName, flashcards: cards)
        }
        FileStorageManager.shared.save(deckData, to: fileName)
    }

    // Loads flashcards from the file and populates the decks dictionary
    // Replace this inside your ViewModel or wherever you're managing flashcards
    func loadFlashcards() {
        let liveFile = "flashcards.json"
        let sampleFile = "sample_flashcards.json"
        
        // Try loading live file first
        if let loadedDecks: [Deck] = FileStorageManager.shared.load(liveFile, as: [Deck].self) {
            print("Loaded decks from live file \(liveFile)")
            for deck in loadedDecks {
                decks[deck.name] = deck.flashcards
            }
        } else if let sampleDecks: [Deck] = FileStorageManager.shared.load(sampleFile, as: [Deck].self) {
            print("Live file not found, loaded sample decks from \(sampleFile)")
            for deck in sampleDecks {
                decks[deck.name] = deck.flashcards
            }
            
            // Save sample decks to live file for next time
            FileStorageManager.shared.save(sampleDecks, to: liveFile)
            print("Saved sample decks to \(liveFile)")
        } else {
            print("No flashcards found")
            decks = [:] // or initialize empty
        }
    }



    // Get flashcards for a specific deck
    func getFlashcards(forDeck deckName: String) -> [Flashcard]? {
        return decks[deckName]
    }
    // Add in FlashcardViewModel
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

    func updateFlashcardReview(deckName: String, flashcard: Flashcard, difficultyLabel: String) {
        guard let index = decks[deckName]?.firstIndex(where: { $0.id == flashcard.id }) else { return }
        
        var card = flashcard
        card.reviewsSoFar += 1

        // Map difficulty to int
        let difficultyInt: Double
        switch difficultyLabel {
        case "Easy": difficultyInt = 1
        case "Good": difficultyInt = 2
        case "Hard": difficultyInt = 3
        case "Again": difficultyInt = 4
        default: difficultyInt = 2
        }

        // Predict new interval
        if let prediction = try? model?.prediction(
            reviews_so_far: Double(card.reviewsSoFar),
            difficulty: difficultyInt,
            last_interval: card.lastInterval
        ) {
            let predictedInterval = prediction.next_session_interval
            card.lastInterval = predictedInterval
            
            if difficultyLabel == "Hard" || difficultyLabel == "Again" {
                // Schedule for immediate repeat
                card.nextReviewDate = Date()
            } else {
                card.nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(predictedInterval.rounded()), to: Date()) ?? Date()
            }
        }

        decks[deckName]?[index] = card
        saveFlashcards()
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

            // Save under deck name like "Sample Deck"
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

// A simple struct to represent a deck with a name and flashcards

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


