// FileStorageManager.swift
import Foundation

class FileStorageManager {
    static let shared = FileStorageManager()
    
    private init() {}
    
    // Get path to Documents directory
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Updated: File path with optional user folder
    private func filePath(for fileName: String, userId: String?) -> URL {
        let fileManager = FileManager.default
        var baseDirectory = getDocumentsDirectory()
        
        if let userId = userId {
            // Create a subdirectory for the user
            baseDirectory = baseDirectory.appendingPathComponent(userId)
            if !fileManager.fileExists(atPath: baseDirectory.path) {
                do {
                    try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true, attributes: nil)
                    print("📁 Created directory for user: \(userId)")
                } catch {
                    print("❌ Error creating user directory: \(error.localizedDescription)")
                }
            }
        }

        return baseDirectory.appendingPathComponent(fileName)
    }
    
    // Save data to file
    func save<T: Codable>(_ data: T, to fileName: String, userId: String? = nil) {
        let url = filePath(for: fileName, userId: userId)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url, options: .atomicWrite)
            print("✅ Successfully saved to: \(url.path)")
        } catch {
            print("❌ Error saving to \(url.lastPathComponent): \(error.localizedDescription)")
        }
    }
    
    // Load data from file
    func load<T: Codable>(_ fileName: String, as type: T.Type, userId: String? = nil) -> T? {
        let url = filePath(for: fileName, userId: userId)
        if !FileManager.default.fileExists(atPath: url.path) {
            print("⚠️ File does not exist at: \(url.path)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(type, from: data)
            print("📥 Loaded data from: \(url.path)")
            return decoded
        } catch {
            print("❌ Error loading from \(url.lastPathComponent): \(error.localizedDescription)")
            return nil
        }
    }
}
