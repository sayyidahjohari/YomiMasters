import Foundation

struct JishoResponse: Decodable {
    let data: [JishoResult]
}

struct JishoResult: Decodable {
    let japanese: [JapaneseWord]
    let senses: [JishoSense]
}

struct JapaneseWord: Decodable {
    let word: String?
    let reading: String?
}

struct JishoSense: Decodable {
    let english_definitions: [String]
    let parts_of_speech: [String]
    let tags: [String]
    let info: [String]
}

// Helper function to format full detailed meaning
func formatJishoResult(_ result: JishoResult) -> String {
    var output = ""

    if let word = result.japanese.first?.word {
        output += "Word: \(word)\n"
    }
    if let reading = result.japanese.first?.reading {
        output += "Reading: \(reading)\n"
    }

    for (index, sense) in result.senses.enumerated() {
        output += "\nMeaning \(index + 1):\n"
        output += "- Definitions: " + sense.english_definitions.joined(separator: ", ") + "\n"
        if !sense.parts_of_speech.isEmpty {
            output += "- Parts of speech: " + sense.parts_of_speech.joined(separator: ", ") + "\n"
        }
        if !sense.tags.isEmpty {
            output += "- Tags: " + sense.tags.joined(separator: ", ") + "\n"
        }
        if !sense.info.isEmpty {
            output += "- Info: " + sense.info.joined(separator: ", ") + "\n"
        }
    }

    return output
}
