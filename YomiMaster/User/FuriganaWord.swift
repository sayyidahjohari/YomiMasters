import Foundation

struct FuriganaWord {
    let kanji: String
    let furigana: String
}

func parseFurigana(from text: String) -> [FuriganaWord] {
    var result: [FuriganaWord] = []
    let regex = try! NSRegularExpression(pattern: "([^<]+)<([^>]+)>", options: [])

    let nsText = text as NSString
    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))

    for match in matches {
        let kanji = nsText.substring(with: match.range(at: 1))
        let furigana = nsText.substring(with: match.range(at: 2))
        result.append(FuriganaWord(kanji: kanji, furigana: furigana))
    }

    return result
}
