import SwiftUI

struct PageContentView: View {
    let content: String
    @Binding var highlightedWords: Set<String>
    @Binding var showFurigana: Bool
    let onWordTap: (String) -> Void
    let onSentenceSelect: (String) -> Void

    var body: some View {
        ScrollView {
            SelectableTextView(
                text: content,
                font: UIFont.systemFont(ofSize: 18),
                onSelection: { selectedText in
                    onSentenceSelect(selectedText)
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
