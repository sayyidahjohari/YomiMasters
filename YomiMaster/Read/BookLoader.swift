import Foundation

struct Page {
    let content: String
}

class BookLoader {
    static func loadBook(from fileName: String, charactersPerPage: Int = 1000) -> [Page] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
              let content = try? String(contentsOf: url) else {
            return []
        }

        // Split content by page separator (-------------)
        let rawPages = content.components(separatedBy: "-----------------------")

        // Trim each page and create a Page object
        let trimmedPages = rawPages.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Concatenate the pages back into a single text
        let fullContent = trimmedPages.joined(separator: "\n")
        
        // Now, paginate the entire content into chunks based on charactersPerPage
        let paginatedContent = paginate(text: fullContent, charactersPerPage: charactersPerPage)
        
        // Create Page objects from paginated content
        let pages = paginatedContent.map { Page(content: $0) }

        return pages
    }
    
    // Pagination function to break the text into smaller pages
    private static func paginate(text: String, charactersPerPage: Int) -> [String] {
        var pages: [String] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            let endIndex = text.index(currentIndex, offsetBy: charactersPerPage, limitedBy: text.endIndex) ?? text.endIndex
            let pageText = String(text[currentIndex..<endIndex])
            pages.append(pageText)
            currentIndex = endIndex
        }

        return pages
    }
}


