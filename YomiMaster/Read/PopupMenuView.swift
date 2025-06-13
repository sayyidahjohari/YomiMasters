import SwiftUI

struct PopupMenuView: View {
    @Binding var showFurigana: Bool
    @Binding var bookmarkedPages: Set<Int>
    @Binding var highlightedWords: Set<HighlightedWord> 
    let pages: [String] // Array of pages to display chapters
    let currentPageIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Show Furigana", isOn: $showFurigana)
                .padding()

            VStack(alignment: .leading) {
                Text("Bookmarks").font(.headline)
                if bookmarkedPages.isEmpty {
                    Text("No bookmarks yet.").foregroundColor(.gray)
                } else {
                    ForEach(bookmarkedPages.sorted(), id: \.self) { page in
                        Text("Page \(page + 1)")
                    }
                }

                Button(action: toggleBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? .red : .primary)
                        .font(.title)
                }
                .padding(.top, 10)
            }

            VStack(alignment: .leading) {
                Text("Highlighted Words").font(.headline)
                if highlightedWords.isEmpty {
                    Text("No highlighted words yet.").foregroundColor(.gray)
                } else {
                    ForEach(Array(highlightedWords), id: \.self) { word in
                        Text("\(word.word) (Page \(word.page + 1))")
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

    private var isBookmarked: Bool {
        bookmarkedPages.contains(currentPageIndex)
    }

    private func toggleBookmark() {
        if isBookmarked {
            bookmarkedPages.remove(currentPageIndex)
        } else {
            bookmarkedPages.insert(currentPageIndex)
        }
    }
}
