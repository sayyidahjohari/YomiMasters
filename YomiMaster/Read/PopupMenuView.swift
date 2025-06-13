import SwiftUI

struct PopupMenuView: View {
    @Binding var showFurigana: Bool
    @Binding var bookmarkedPages: [Int]
    @Binding var highlightedWords: Set<String>
    let pages: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Show Furigana", isOn: $showFurigana)
                .padding()

            VStack(alignment: .leading) {
                Text("Bookmarks").font(.headline)
                if bookmarkedPages.isEmpty {
                    Text("No bookmarks yet.").foregroundColor(.gray)
                } else {
                    ForEach(bookmarkedPages, id: \.self) { page in
                        Text("Page \(page + 1)")
                    }
                }
            }

            VStack(alignment: .leading) {
                Text("Highlighted Words").font(.headline)
                if highlightedWords.isEmpty {
                    Text("No highlighted words yet.").foregroundColor(.gray)
                } else {
                    ForEach(Array(highlightedWords), id: \.self) { word in
                        Text(word)
                    }
                }
            }

            VStack(alignment: .leading) {
                Text("Chapters").font(.headline)
                ForEach(0..<pages.count, id: \.self) { index in
                    Text("Chapter \(index + 1)")
                }
            }
        }
        .padding()
    }
}
