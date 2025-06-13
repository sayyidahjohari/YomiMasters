import SwiftUI

struct SentenceView: View {
    let sentence: String
    @Binding var highlightedWords: Set<String>
    @Binding var showFurigana: Bool
    let onWordTap: (String) -> Void
    let onSentenceSelect: (String) -> Void

    var body: some View {
        HStack {
            let words = sentence.split(separator: " ").map { String($0) }
            ForEach(words, id: \.self) { word in
                VStack {
                    if showFurigana {
                        Text(getFurigana(for: word))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Text(word)
                        .font(.body)
                        .padding(2)
                        .background(highlightedWords.contains(word) ? Color.yellow : Color.clear)
                        .onTapGesture {
                            onWordTap(word)
                        }
                        .contextMenu {
                            Button("Highlight") {
                                highlightedWords.insert(word)
                            }
                            Button("Undo Highlight") {
                                highlightedWords.remove(word)
                            }
                            Button("Lookup Sentence") {
                                onSentenceSelect(sentence)
                            }
                        }
                }
            }
        }
        .padding(.vertical, 5)
    }
}

private func getFurigana(for word: String) -> String {
    return "（ふりがな）"
}
