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
