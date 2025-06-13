import Foundation

func translateWithMicrosoft(text: String, completion: @escaping (String?) -> Void) {
    let apiKey = "2MNeOUqZP7nuu5fJAylVQAlKHfYK7MCUU14WHohZyk7kSrtw014tJQQJ99BEACqBBLyXJ3w3AAAbACOG06sj" // replace with your real key
    let endpoint = "https://api.cognitive.microsofttranslator.com"
    let region = "southeastasia" // use lowercase, no space

    let urlString = "\(endpoint)/translate?api-version=3.0&to=en"
    guard let url = URL(string: urlString) else {
        print("❌ Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    request.addValue(region, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")

    let requestBody: [[String: String]] = [["Text": text]]
    request.httpBody = try? JSONEncoder().encode(requestBody)

    print("📤 Sending request to Microsoft Translator: \(text)")

    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let data = data else {
            print("❌ No data received")
            completion(nil)
            return
        }

        if let responseText = String(data: data, encoding: .utf8) {
            print("📥 Response: \(responseText)")
        }

        if let result = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let translations = result.first?["translations"] as? [[String: Any]],
           let translation = translations.first?["text"] as? String {
            print("✅ Translation success: \(translation)")
            completion(translation)
        } else {
            print("❌ Failed to parse translation")
            completion(nil)
        }
    }.resume()
}
