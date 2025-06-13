// JishoAPIManager.swift
import Foundation

struct JishoResult: Codable {
    let data: [JishoWord]
}

struct JishoWord: Codable {
    let slug: String
    let isCommon: Bool?
    let japanese: [Japanese]
    let senses: [Sense]
}

struct Japanese: Codable {
    let word: String?
    let reading: String
}

struct Sense: Codable {
    let english_definitions: [String]
    let parts_of_speech: [String]
    let tags: [String]
}

class JishoAPIManager {
    static let shared = JishoAPIManager()

    func searchWord(_ word: String, completion: @escaping (JishoWord?) -> Void) {
        let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? word
        let urlString = "https://jisho.org/api/v1/search/words?keyword=\(encodedWord)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(JishoResult.self, from: data)
                completion(result.data.first)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
