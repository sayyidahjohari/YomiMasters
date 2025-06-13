import Foundation

struct JishoWord: Codable {
    let japanese: [Japanese]
    let senses: [Sense]

    struct Japanese: Codable {
        let word: String?
        let reading: String?
    }

    struct Sense: Codable {
        let english_definitions: [String]
    }
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

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(JishoSearchResult.self, from: data)
                completion(result.data.first)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    struct JishoSearchResult: Codable {
        let data: [JishoWord]
    }
}


