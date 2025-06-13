import SwiftUI

struct FlashcardView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @State private var isFlipped = false
    @State private var timerValue = 60
    @State private var timerRunning = false
    @State private var currentIndex = 0

    var flashcards: [Flashcard]
    var deckName: String

    var body: some View {
        NavigationStack {
            if currentIndex < flashcards.count {
                let flashcard = flashcards[currentIndex]

                ZStack {
                    Color(red: 0.96, green: 0.94, blue: 0.88)
                        .ignoresSafeArea()

                    VStack {
                        HStack {
                            Spacer()
                            TimerView(timerValue: $timerValue, timerRunning: $timerRunning)
                                .padding()
                        }

                        Spacer()

                        ZStack {
                            if isFlipped {
                                VStack {
                                    Text(flashcard.japaneseWord)
                                        .font(.largeTitle).bold()
                                    Divider().padding(.vertical)

                                    Text(flashcard.meaning)
                                        .font(.title).bold().foregroundColor(.blue)

            
                                    Spacer()

                                    HStack(spacing: 20) {
                                        ForEach(["Easy", "Good", "Hard", "Again"], id: \.self) { level in
                                            Button(level) {
                                                handleReview(level: level)
                                            }
                                            .buttonStyle(OptionButtonStyle(color: colorFor(level)))
                                        }
                                    }

                                    
                                    .padding()
                                    .buttonStyle(OptionButtonStyle(color: .gray))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .padding()
                            } else {
                                VStack {
                                    Text(flashcard.japaneseWord)
                                        .font(.largeTitle).bold()
                                        .foregroundColor(.black)
                                    Text("Tap to reveal")
                                        .font(.subheadline).foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .padding()
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                isFlipped.toggle()
                            }
                        }

                        Spacer()
                    }
                    .padding()
                }
                .ignoresSafeArea()
            } else {
                // Finished all cards
                VStack {
                    Text("Deck Completed!")
                        .font(.largeTitle)
                        .padding()
                    
                }
            }
        }
    }

    func handleReview(level: String) {
        print("Reviewed with difficulty: \(level)")
        if currentIndex < flashcards.count {
            let flashcard = flashcards[currentIndex]
            flashcardViewModel.updateFlashcardReview(deckName: deckName, flashcard: flashcard, difficultyLabel: level)
        }
        withAnimation {
            isFlipped = false
            currentIndex += 1
        }
    }

    


    func colorFor(_ level: String) -> Color {
        switch level {
        case "Easy": return .green
        case "Good": return .blue
        case "Hard": return .orange
        case "Again": return .red
        default: return .gray
        }
    }
}

struct SampleDeckView: View {
    var body: some View {
        let sampleDeck = [
            Flashcard(japaneseWord: "歩く", meaning: "To walk", exampleSentence: "森を歩いていました。", pronunciation: "あるく"),
            Flashcard(japaneseWord: "食べる", meaning: "To eat", exampleSentence: "りんごを食べます。", pronunciation: "たべる"),
            Flashcard(japaneseWord: "見る", meaning: "To see", exampleSentence: "映画を見る。", pronunciation: "みる")
        ]
        NavigationStack {
            FlashcardView(flashcards: sampleDeck, deckName: "Sample")
                .environmentObject(FlashcardViewModel())
        }
    }
}


    
struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardView(
            flashcards: [
                Flashcard(
                    japaneseWord: "歩く",
                    meaning: "To walk",
                    exampleSentence: "森を歩いていました。 (I was walking through the forest.)",
                    pronunciation: "あるく (aruku)"
                )
            ],
            deckName: "Sample Deck"
        )

        .environmentObject(FlashcardViewModel())
    }
}
