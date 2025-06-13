import Foundation

class BookLoader {
    static func loadTextFile(named fileName: String) -> String {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") else {
            return "Failed to find file \(fileName).txt"
        }

        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            return content
        } catch {
            return "Error reading file \(fileName): \(error.localizedDescription)"
        }
    }
}
