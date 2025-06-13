import Foundation

func fetchWordDataFromJisho(for word: String, completion: @escaping (String, String) -> Void) {
    let urlString = "https://jisho.org/api/v1/search/words?keyword=\(word)"
    
    guard let url = URL(string: urlString) else {
        completion("Error", "Failed to create URL.")
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            completion("Error", "Request failed: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            completion("Error", "No data received.")
            return
        }
        
        do {
            // Parsing the Jisho API response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]],
               let firstResult = dataArray.first,
               let senses = firstResult["senses"] as? [[String: Any]],
               let sense = senses.first {
                
                // Extracting meaning and part of speech
                let meaning = sense["english_definitions"] as? [String] ?? ["No definition available."]
                let pos = sense["parts_of_speech"] as? [String] ?? ["Unknown part of speech"]
                
                let definition = meaning.joined(separator: ", ")
                let partOfSpeech = pos.joined(separator: ", ")
                
                completion(definition, partOfSpeech)
            } else {
                completion("Error", "Failed to extract information from response.")
            }
        } catch {
            completion("Error", "Failed to parse response.")
        }
    }
    
    task.resume()
}
