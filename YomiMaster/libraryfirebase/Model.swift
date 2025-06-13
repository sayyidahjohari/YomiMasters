//
//  Model.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 01/06/2025.
//

import Foundation
import Swift
import Firebase
import FirebaseStorage
import FirebaseFirestore



struct Bookfb: Identifiable {
    var id: String
    var title: String
    var filename: String
    var level: String
    var tags: [String]
    var genre: String
    var coverImageUrl: String?
    var description: String
}

class BooksViewModel: ObservableObject {
    @Published var booksByLevel: [String: [Bookfb]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    func fetchBooks() {
        print("Starting fetchBooks()")
        isLoading = true
        errorMessage = nil
        
        db.collection("books").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Firestore error:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in Firestore 'books' collection")
                DispatchQueue.main.async {
                    self.errorMessage = "No books found"
                }
                return
            }
            
            print("Documents fetched:", documents.count)
            var grouped: [String: [Bookfb]] = [:]
            
            for doc in documents {
                let data = doc.data()
                print("Document data:", data)
                
                let book = Bookfb(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "No Title",
                    filename: data["filename"] as? String ?? "",
                    level: data["level"] as? String ?? "Unknown",
                    tags: data["tags"] as? [String] ?? [],
                    genre: data["genre"] as? String ?? "",
                    coverImageUrl: data["coverImageUrl"] as? String,
                    description: data["description"] as? String ?? ""
                )
                
                grouped[book.level, default: []].append(book)
            }
            
            DispatchQueue.main.async {
                self.booksByLevel = grouped
                print("Books grouped by level:", self.booksByLevel.keys.sorted())
            }
        }
    }
}

struct Pages: Identifiable {//
    let id = UUID()
    let content: String
}

class BookContentViewModel: ObservableObject {
    @Published var pages: [Pages] = []
    @Published var isLoading = false
    
    func fetchBookContent(filename: String) {
        isLoading = true
        let storage = Storage.storage()
        let fileRef = storage.reference().child("books/\(filename)")
        
        fileRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let data = data, let contentString = String(data: data, encoding: .utf8) {
                let rawPages = contentString.components(separatedBy: "-----------------------")
                let trimmedPages = rawPages
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                DispatchQueue.main.async {
                    self.pages = trimmedPages.map { Pages(content: $0) }
                }
            } else {
                print("Failed to fetch book content:", error?.localizedDescription ?? "Unknown error")
                DispatchQueue.main.async {
                    self.pages = [Pages(content: "Failed to load book content.")]
                }
            }
        }
    }
}
