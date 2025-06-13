import SwiftUI

struct DeckListView: View {
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel

    @State private var showingEditDeckSheet = false
    @State private var selectedDeckName: String = ""
    @State private var newDeckName = ""

    @State private var showingAddDeckSheet = false
    @State private var addDeckName = ""

    @State private var deckToDelete: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.warmBeige.opacity(0.9),
                        Color.dustyRose.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )


                VStack {
                    Spacer()
                    Text("Flashcard Decks")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(.top, 50)

                    Spacer()

                    VStack {
                        Spacer()

                        // Add Deck Button
                        HStack {
                            Spacer()
                            Button(action: {
                                showingAddDeckSheet.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .font(.title2)
                                    Text("Add Deck")
                                        .font(.headline)
                                }
                                .padding()
                            }
                        }

                        // Header
                        HStack {
                            Spacer(minLength: 30)
                            Text("Deck")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Cards")
                                .frame(width: 150, alignment: .center)
                            Spacer(minLength: 100)
                        }
                        .padding(.trailing, 50)
                        .fontWeight(.bold)
                        Divider()

                        let deckList = flashcardViewModel.decks.map { Deck(name: $0.key, flashcards: $0.value) }

                        List {
                            ForEach(deckList, id: \.name) { deck in
                                NavigationLink(
                                    destination: FlashcardListView(deckName: deck.name)
                                ) {
                                    DeckRowView(
                                        deck: deck,
                                        onEdit: {
                                            selectedDeckName = deck.name
                                            newDeckName = deck.name
                                            showingEditDeckSheet.toggle()
                                        },
                                        onDelete: {
                                            deckToDelete = deck.name
                                        }
                                    )
                                }
                            }
                            .onDelete { indexSet in
                                let keys = deckList.map { $0.name }
                                for index in indexSet {
                                    let key = keys[index]
                                    flashcardViewModel.deleteDeck(named: key)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    .padding()
                    .background(Color.clear)
                }
            }
            .ignoresSafeArea()
        }
        .edgesIgnoringSafeArea(.all)

        // Add Deck Sheet
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

        // Edit Deck Name Sheet
        .sheet(isPresented: $showingEditDeckSheet, onDismiss: {
            newDeckName = ""
        }) {
            VStack(spacing: 20) {
                Text("Edit Deck Name")
                    .font(.title)
                    .padding()

                TextField("New Deck Name", text: $newDeckName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                HStack {
                    Button("Cancel") {
                        showingEditDeckSheet = false
                    }
                    .padding()
                    .foregroundColor(.red)

                    Spacer()

                    Button("Save") {
                        guard !newDeckName.isEmpty,
                              newDeckName != selectedDeckName,
                              flashcardViewModel.decks[newDeckName] == nil else { return }

                        let cards = flashcardViewModel.decks.removeValue(forKey: selectedDeckName)
                        flashcardViewModel.decks[newDeckName] = cards ?? []
                        flashcardViewModel.saveFlashcards()
                        showingEditDeckSheet = false
                    }
                    .padding()
                    .disabled(newDeckName.isEmpty || flashcardViewModel.decks.keys.contains(newDeckName))
                }
                .padding(.horizontal)
            }
            .padding()
        }

        // Delete Confirmation Alert
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

        // Load decks on appear
        .onAppear {
            flashcardViewModel.loadFlashcards()

            if flashcardViewModel.decks.isEmpty {
                print("🟡 No decks found — generating sample deck")
                flashcardViewModel.generateAndSaveSampleFlashcards()
                flashcardViewModel.loadFlashcards() // <-- force reload after save
            } else {
                print("🟢 Loaded \(flashcardViewModel.decks.count) decks")
            }
        }

    }
}

// MARK: - Reusable Row View
struct DeckRowView: View {
    let deck: Deck
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(deck.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(deck.flashcards.count)")
                .foregroundColor(.blue)
                .frame(width: 150, alignment: .center)

            Spacer(minLength: 80)

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
    }
}

// MARK: - Preview
struct DeckListView_Previews: PreviewProvider {
    static var previews: some View {
        DeckListView()
            .environmentObject(FlashcardViewModel())
    }
}
