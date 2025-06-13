import Foundation

class BookReaderViewModel: ObservableObject {
    @Published var pages: [Page] = []
    @Published var currentPageIndex = 0

    var currentPage: Page {
        pages.isEmpty ? Page(content: "No content") : pages[currentPageIndex]
    }

    func loadBook(named fileName: String) {
        pages = BookLoader.loadBook(from: fileName) // This now loads paginated content
    }

    func nextPage() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
        }
    }

    func previousPage() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
}

