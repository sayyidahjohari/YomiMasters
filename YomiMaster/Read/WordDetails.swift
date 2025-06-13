//
//  WordDetails.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 15/04/2025.
//


struct WordDetails {
    let word: String
    let meaning: String
    let furigana: String
    let grammarExplanation: String
    let context: String
    let exampleUsage: String
}

struct HighlightedWord: Hashable {
    let word: String
    let page: Int
    let indexInPage: Int // This represents the word's position on the page
    
    // We need to ensure that the equality is checked on all 3 properties: word, page, and indexInPage
    static func == (lhs: HighlightedWord, rhs: HighlightedWord) -> Bool {
        return lhs.word == rhs.word && lhs.page == rhs.page && lhs.indexInPage == rhs.indexInPage
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(page)
        hasher.combine(indexInPage)
    }
}
