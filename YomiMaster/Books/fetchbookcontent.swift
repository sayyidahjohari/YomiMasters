import Foundation
import FirebaseStorage

func fetchBookContent(bookPath: String, completion: @escaping (String?) -> Void) {
    let storageRef = Storage.storage().reference().child(bookPath)
    
    storageRef.downloadURL { url, error in
        if let error = error {
            print("Error getting download URL: \(error)")
            completion(nil)
        } else if let url = url {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let content = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        completion(content)
                    }
                } else {
                    print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }.resume()
        }
    }
}
