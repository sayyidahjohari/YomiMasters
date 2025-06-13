import SwiftUI
import FirebaseAuth

struct DeckListView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @EnvironmentObject var authService: AuthService

    @State private var showingDeckEditor = false
    @State private var editingDeck: Deck? = nil

    @State private var showingAddDeckSheet = false
    @State private var addDeckName = ""

    @State private var deckToDelete: String? = nil

    @State private var showingProfileSheet = false  // New: profile sheet flag

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.88)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Top bar with title at left and profile button at right
                    HStack {
                        Text("Flashcard Decks")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .padding(.leading, 20)
                            .padding(.top, 50)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showingProfileSheet.toggle()
                            }
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddDeckSheet.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Add Deck")
                                    .font(.headline)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.trailing)
                    }

                    Divider()

                    let deckList = flashcardViewModel.decks
                        .sorted { $0.key.localizedCompare($1.key) == .orderedAscending }
                        .map { Deck(name: $0.key, flashcards: $0.value) }

                    ScrollView {
                        VStack {
                            VStack(spacing: 18) {
                                ForEach(deckList, id: \.name) { deck in
                                    DeckRowView(
                                        deck: deck,
                                        onEdit: {
                                            editingDeck = deck
                                            showingDeckEditor = true
                                        },
                                        onDelete: {
                                            deckToDelete = deck.name
                                        },
                                        onSelect: {}
                                    )
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(LinearGradient.dustyRose2gradient)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
            }
            .ignoresSafeArea()
            //.navigationTitle("Decks") // Removed
        }

        // === Existing Add Deck sheet ===
        .sheet(isPresented: $showingAddDeckSheet, onDismiss: {
            addDeckName = ""
        }) {
            VStack {
                Text("Add New Deck")
                    .font(.title)
                    .padding()

                TextField("Deck Name", text: $addDeckName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Button("Add Deck") {
                    guard !addDeckName.isEmpty,
                          flashcardViewModel.decks[addDeckName] == nil else { return }

                    flashcardViewModel.decks[addDeckName] = []
                    flashcardViewModel.saveFlashcards()
                    showingAddDeckSheet = false
                    addDeckName = ""
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(addDeckName.isEmpty || flashcardViewModel.decks.keys.contains(addDeckName))
            }
            .padding()
        }

        // === Existing Edit Deck sheet ===
        .sheet(isPresented: $showingDeckEditor, onDismiss: {
            if let deck = editingDeck {
                flashcardViewModel.decks[deck.name] = deck.flashcards
                flashcardViewModel.saveFlashcards()
                editingDeck = nil
            }
        }) {
            if let binding = Binding($editingDeck) {
                DeckEditorView(deck: binding) {
                    showingDeckEditor = false
                }
            } else {
                Text("No deck selected")
            }
        }

        // === New Profile sheet ===
        .sheet(isPresented: $showingProfileSheet) {
            ProfileView()
                .environmentObject(authService)
        }

        // === Delete Deck alert ===
        .alert("Delete Deck?", isPresented: .constant(deckToDelete != nil), presenting: deckToDelete) { deckName in
            Button("Delete", role: .destructive) {
                flashcardViewModel.deleteDeck(named: deckName)
                deckToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                deckToDelete = nil
            }
        } message: { deckName in
            Text("Are you sure you want to delete the deck '\(deckName)'?")
        }

        // === On appear: load or generate sample decks ===
        .onAppear {
            flashcardViewModel.loadFlashcards()

            if flashcardViewModel.decks.isEmpty {
                print("🟡 No decks found — generating sample deck")
                flashcardViewModel.generateAndSaveSampleFlashcards()
                flashcardViewModel.loadFlashcards()
            } else {
                print("🟢 Loaded \(flashcardViewModel.decks.count) decks")
            }
        }
    }
}



// ------------------------------------
// PreviewProvider for DeckListView
// ------------------------------------
struct DeckListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockVM = FlashcardViewModel()
        mockVM.decks = [
            "N5 Vocabulary": [
                Flashcard(japaneseWord: "猫", meaning: "Cat"),
                Flashcard(japaneseWord: "犬", meaning: "Dog")
            ],
            "N4 Verbs": [
                Flashcard(japaneseWord: "食べる", meaning: "Eat"),
                Flashcard(japaneseWord: "歩く", meaning: "Walk"),
                Flashcard(japaneseWord: "読む", meaning: "Read")
            ]
        ]
        return DeckListView()
            .environmentObject(mockVM)
            .previewDevice("iPhone 15")
    }
}
