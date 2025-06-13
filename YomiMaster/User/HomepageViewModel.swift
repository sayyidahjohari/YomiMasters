//
//  HomepageViewModel.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//


//
//  HomepageViewModel.swift
//  Yomi Master
//
//  Created by Sayyidah Nafisah on 29/12/2024.
//


// HomepageViewModel.swift
import SwiftUI

class HomepageViewModel: ObservableObject {
    @Published var userName: String = "Yomi"
    @Published var streakDays: Int = 5
    @Published var wordsLearned: Int = 10
    @Published var totalWords: Int = 20
    @Published var pagesRead: Int = 15
    @Published var totalPages: Int = 30
    @Published var flashcardsReviewed: Int = 8
    @Published var totalFlashcards: Int = 10
    @Published var searchText: String = ""
    
    var streakMessage: String {
            "🔥 \(streakDays)-day streak! Keep it up!"
        }
    
    // Books Data
    let books: [Book] = [
        Book(title: "Book One", author: "Author A", cover: "book", currentPage: 190, totalPages: 300),
        Book(title: "Book Two", author: "Author B", cover: "book", currentPage: 190, totalPages: 356),
        Book(title: "Book Three", author: "Author C", cover: "book", currentPage: 10, totalPages: 100),
        Book(title: "Book Four", author: "Author D", cover: "book", currentPage: 1000, totalPages: 1050),
        Book(title: "Book Five", author: "Author E", cover: "book", currentPage: 100, totalPages: 350)
    ]
}

// MARK: - Book Model
struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let cover: String
    let currentPage: Int
    let totalPages: Int
    
    // Calculate progress as a percentage (value between 0 and 1)
    var progress: Double {
        guard totalPages > 0 else { return 0.0 }
        return Double(currentPage) / Double(totalPages)
    }
}


//
