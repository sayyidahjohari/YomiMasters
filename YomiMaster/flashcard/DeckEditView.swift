import SwiftUI

struct DeckEditorView: View {
    @Binding var deck: Deck
    var onSave: () -> Void

    @State private var newWord = ""
    @State private var newMeaning = ""
    @State private var editingIndex: Int? = nil
    @State private var showDeleteAlert = false
    @State private var indexToDelete: Int? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Deck Name")) {
                    TextField("Deck Name", text: $deck.name)
                        .textFieldStyle(.roundedBorder)
                }

                Section(header: Text("Add New Flashcard")) {
                    TextField("Word", text: $newWord)
                    TextField("Meaning", text: $newMeaning)
                    Button("Add Flashcard") {
                        let newFlashcard = Flashcard(japaneseWord: newWord, meaning: newMeaning)
                        deck.flashcards.append(newFlashcard)
                        newWord = ""
                        newMeaning = ""
                    }
                    .disabled(newWord.isEmpty || newMeaning.isEmpty)
                }

                Section(header: Text("Flashcards in Deck")) {
                    ForEach(deck.flashcards.indices, id: \.self) { index in
                        HStack {
                            if editingIndex == index {
                                VStack(alignment: .leading) {
                                    TextField("Word", text: $deck.flashcards[index].japaneseWord)
                                        .textFieldStyle(.roundedBorder)
                                    TextField("Meaning", text: $deck.flashcards[index].meaning)
                                        .textFieldStyle(.roundedBorder)
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text(deck.flashcards[index].japaneseWord)
                                        .fontWeight(.bold)
                                    Text(deck.flashcards[index].meaning)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()

                            // Edit Button
                            Button(action: {
                                if editingIndex == index {
                                    editingIndex = nil // Done editing
                                } else {
                                    editingIndex = index // Start editing this one
                                }
                            }) {
                                Image(systemName: editingIndex == index ? "checkmark" : "pencil")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.trailing, 6)

                            // Delete Button
                            Button(role: .destructive) {
                                indexToDelete = index
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Edit Deck")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
            .alert("Delete Flashcard?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let index = indexToDelete {
                        deck.flashcards.remove(at: index)
                    }
                    indexToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    indexToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this flashcard?")
            }
        }
    }
}
