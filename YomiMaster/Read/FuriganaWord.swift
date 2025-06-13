import Foundation

struct FuriganaWord {
    let kanji: String
    let furigana: String
}

func parseFurigana(from text: String) -> [FuriganaWord] {
    var result: [FuriganaWord] = []
    let regex = try! NSRegularExpression(pattern: "([^《]+)《([^》]+)》", options: [])

    let nsText = text as NSString
    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))

    for match in matches {
        let kanji = nsText.substring(with: match.range(at: 1))
        let furigana = nsText.substring(with: match.range(at: 2))
        
        // Only add the word if it is not already in the result (avoid duplicates)
        if !result.contains(where: { $0.kanji == kanji && $0.furigana == furigana }) {
            result.append(FuriganaWord(kanji: kanji, furigana: furigana))
        }
    }

    return result
}
