import SwiftUI

struct DefinitionPopupView: View {
    let selectedWord: String
    let sentenceContext: String
    let meaning: String
    let furigana: String
    let grammarExplanation: String
    let exampleUsage: String
    @Binding var showPopup: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text(selectedWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .background(Color.softPink)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 15) {
                SectionTitle(title: "Meaning", color: .blue)
                Text(meaning)

                SectionTitle(title: "Context in Sentence", color: .purple)
                Text("The phrase \(selectedWord) means '\(meaning)' as part of the sentence '\(sentenceContext)'.")

                SectionTitle(title: "Grammar", color: .green)
                Text(grammarExplanation)

                SectionTitle(title: "Reading (Furigana)", color: .orange)
                Text(furigana)

                SectionTitle(title: "Example Usage", color: .red)
                Text(exampleUsage)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)

            Button("Add to Flashcard") {
                print("Added \(selectedWord) to flashcard")
                showPopup = false
            }
            .padding()
            .background(Color.softPink)
            .cornerRadius(10)

            Button("Close") {
                showPopup = false
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
    }
}
