import Foundation

struct Page {
    let content: String
}

class BookLoader {
    static func loadBook(from fileName: String) -> [Page] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
              let content = try? String(contentsOf: url) else {
            return []
        }

        // Split content by page separator (-------------)
        let rawPages = content.components(separatedBy: "-------------------------------------------------------")

        // Trim each page and create a Page object
        let pages = rawPages.map { Page(content: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }

        return pages
    }
}
