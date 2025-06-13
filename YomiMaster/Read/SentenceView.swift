import SwiftUI

struct SentenceView: View {
    let sentence: String
    let onWordTap: (String) -> Void
    @Binding var highlightedWords: Set<String>

    var body: some View {
        let words = sentence.components(separatedBy: .whitespaces)
        return HStack {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .padding(2)
                    .background(highlightedWords.contains(word) ? Color.yellow.opacity(0.5) : Color.clear)
                    .cornerRadius(4)
                    .onTapGesture {
                        onWordTap(word)
                    }
            }
        }
    }
}
