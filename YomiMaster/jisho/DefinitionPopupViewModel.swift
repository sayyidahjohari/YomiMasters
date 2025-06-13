import Foundation
import Combine

class DefinitionPopupViewModel: ObservableObject {
    @Published var jishoResult: JishoWord?

    func fetchJishoDefinition(for word: String) {
        JishoAPIManager.shared.searchWord(word) { result in
            DispatchQueue.main.async {
                self.jishoResult = result
            }
        }
    }

    var romaji: String? {
        if let reading = jishoResult?.japanese.first?.reading {
            return KanaKit().romaji(from: reading)
        }
        return nil
    }

    var meaning: String {
        jishoResult?.senses.first?.english_definitions.joined(separator: ", ") ?? "No meaning found"
    }

    var reading: String {
        jishoResult?.japanese.first?.reading ?? ""
    }
}
