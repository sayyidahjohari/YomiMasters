import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct AdminUploadView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var filename = ""
    @State private var genre = ""
    @State private var level = "N5"
    @State private var tags = ""
    
    @State private var showFilePicker = false
    @State private var showImagePicker = false
    @State private var txtFileURL: URL? = nil
    @State private var coverImage: UIImage? = nil
    @State private var isUploading = false
    @State private var uploadStatus: String? = nil

    let levels = ["N5", "N4", "N3", "N2", "N1"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Filename (e.g. book1.txt)", text: $filename)
                    TextField("Genre", text: $genre)
                    Picker("Level", selection: $level) {
                        ForEach(levels, id: \.self) { level in
                            Text(level)
                        }
                    }
                    TextField("Tags (comma-separated)", text: $tags)
                }

                Section(header: Text("Files")) {
                    Button("Select .txt Book File") {
                        showFilePicker.toggle()
                    }
                    if let fileURL = txtFileURL {
                        Text("Selected: \(fileURL.lastPathComponent)")
                    }

                    Button("Select Cover Image") {
                        showImagePicker.toggle()
                    }
                    if coverImage != nil {
                        Text("Cover Image Selected")
                    }
                }

                if isUploading {
                    ProgressView("Uploading...")
                } else {
                    Button("Upload Book to Firebase") {
                        uploadBook()
                    }
                }

                if let status = uploadStatus {
                    Text(status).foregroundColor(.blue)
                }
            }
            .navigationTitle("Upload Book")
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                txtFileURL = urls.first
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $coverImage)
        }
    }

    func uploadBook() {
        guard let txtFileURL = txtFileURL else {
            uploadStatus = "Please select a .txt file"
            return
        }

        isUploading = true
        uploadStatus = nil
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let txtRef = storageRef.child("books/\(filename)")

        // Upload the .txt file
        txtRef.putFile(from: txtFileURL, metadata: nil) { _, error in
            if let error = error {
                uploadStatus = "Text file upload failed: \(error.localizedDescription)"
                isUploading = false
                return
            }

            // Upload cover image if provided
            if let image = coverImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageID = UUID().uuidString
                let imageRef = storageRef.child("covers/\(imageID).jpg")

                imageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        uploadStatus = "Image upload failed: \(error.localizedDescription)"
                        isUploading = false
                        return
                    }

                    imageRef.downloadURL { url, error in
                        saveBookToFirestore(coverURL: url?.absoluteString)
                    }
                }
            } else {
                saveBookToFirestore(coverURL: nil)
            }
        }
    }

    func saveBookToFirestore(coverURL: String?) {
        let db = Firestore.firestore()
        let docRef = db.collection("books").document()

        let tagArray = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let data: [String: Any] = [
            "title": title,
            "description": description,
            "filename": filename,
            "genre": genre,
            "level": level,
            "tags": tagArray,
            "coverImageUrl": coverURL ?? ""
        ]

        docRef.setData(data) { error in
            DispatchQueue.main.async {
                isUploading = false
                if let error = error {
                    uploadStatus = "Failed to save to Firestore: \(error.localizedDescription)"
                } else {
                    uploadStatus = "Upload successful!"
                    resetForm()
                }
            }
        }
    }

    func resetForm() {
        title = ""
        description = ""
        filename = ""
        genre = ""
        level = "N5"
        tags = ""
        txtFileURL = nil
        coverImage = nil
    }
}
