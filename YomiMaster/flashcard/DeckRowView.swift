import Foundation
import SwiftUI

struct DeckRowView: View {
    let deck: Deck
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 16.0) {
            NavigationLink(destination: FlashcardView(flashcards: deck.flashcards, deckName: deck.name)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("\(deck.flashcards.count) cards")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
            }
        }
        .padding(24) // ✅ Bigger padding inside the card
        .frame(maxWidth: .infinity) // ✅ Make it wider
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.warmBeige) // or Color.white
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


extension LinearGradient {
    static let dustyRose2gradient = LinearGradient(
        colors: [
            Color(red: 0.78, green: 0.60, blue: 0.65),   // Slightly deeper rose
            Color(red: 0.97, green: 0.92, blue: 0.89)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Helper to bind optional
extension Binding {
    init?(_ source: Binding<Value?>) {
        guard let value = source.wrappedValue else { return nil }
        self.init(
            get: { value },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}

