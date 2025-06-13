import Foundation

class DefinitionPopupViewModel: ObservableObject {
    @Published var jishoMeaning: String = "Loading..."
    @Published var reading: String = ""

    func fetchDefinition(for word: String) {
        JishoAPIManager.shared.searchWord(word) { result in
            DispatchQueue.main.async {
                if let wordData = result {
                    self.jishoMeaning = wordData.senses.first?.english_definitions.joined(separator: ", ") ?? "No meaning found"
                    self.reading = wordData.japanese.first?.reading ?? ""
                } else {
                    self.jishoMeaning = "Definition not found"
                }
            }
        }
    }
}
