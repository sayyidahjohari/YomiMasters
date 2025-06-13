//
//  FlashcardLoader.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 25/05/2025.
//


import Foundation

class FlashcardLoader {
    static func loadSampleFlashcards() -> [Flashcard] {
        guard let url = Bundle.main.url(forResource: "sample_flashcards", withExtension: "json") else {
            print("⚠️ JSON file not found.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let flashcards = try decoder.decode([Flashcard].self, from: data)
            return flashcards
        } catch {
            print("❌ Error loading flashcards: \(error)")
            return []
        }
    }
}
