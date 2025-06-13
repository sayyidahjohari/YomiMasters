//
//  FileStorageManager.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 14/05/2025.
//


// FileStorageManager.swift
import Foundation

class FileStorageManager {
    static let shared = FileStorageManager()
    
    private init() {}
    
    // Get path to local JSON file
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func filePath(for fileName: String) -> URL {
        getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    // Save to file
    func save<T: Codable>(_ data: T, to fileName: String) {
        let url = filePath(for: fileName)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted  // optional: makes JSON readable
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url, options: .atomicWrite)
            print("✅ Successfully saved flashcards to: \(url.path)")
        } catch {
            print("❌ Error saving flashcards to \(url.path): \(error.localizedDescription)")
        }
    }
    
    func load<T: Codable>(_ fileName: String, as type: T.Type) -> T? {
        let url = filePath(for: fileName)
        if !FileManager.default.fileExists(atPath: url.path) {
            print("⚠️ File does not exist at: \(url.path)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(type, from: data)
            print("📥 Successfully loaded flashcards from: \(url.path)")
            return decoded
        } catch {
            print("❌ Error loading flashcards from \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
}
