import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth//



struct AdminUploadView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var filename = ""
    @State private var genre = "Other"
    @State private var level = "N5"
    @State private var showProfile = false
    @EnvironmentObject var authService: AuthService


    let allTags = ["Fiction", "Non-fiction", "History", "Language", "Culture", "Education", "Science"]
    @State private var selectedTags: Set<String> = []

    @State private var showFilePicker = false
    @State private var showImagePicker = false
    @State private var txtFileURL: URL? = nil
    @State private var coverImage: UIImage? = nil
    @State private var isUploading = false
    @State private var uploadStatus: String? = nil
    @State private var showStatus = false

    let levels = ["N5", "N4", "N3", "N2", "N1"]
    let genres = ["Other", "Novel", "Manga", "Essay", "Poetry", "Technical", "Children"]

    var body: some View {
        NavigationStack {
            
            HStack {
                 Text("Admin Upload")
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .foregroundColor(.black)
                     .padding(.leading, 16)
                 
                 Spacer()
                 
                 Button {
                     showProfile = true
                 } label: {
                     Image(systemName: "person.crop.circle")
                         .imageScale(.large)
                         .foregroundColor(.black)
                 }
                 .padding(.trailing, 16)
             }
             .frame(height: 60)
             .background(Color.warmBeige)
             .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
             .zIndex(1)  // ensures header stays above scroll content
             
            ScrollView {
                VStack(spacing: 20) {
                    Text("📘 Upload New Book")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)

                    Group {
                        UploadPicker(label: "Book File (.txt)", icon: "doc.text", selectedText: txtFileURL?.lastPathComponent ?? "Select .txt Book File") {
                            showFilePicker = true
                        }

                        UploadPicker(label: "Cover Image (optional)", icon: "photo", selectedText: coverImage == nil ? "Select Cover Image" : "Cover Image Selected") {
                            showImagePicker = true
                        }

                        if let coverImage = coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(12)
                                .shadow(radius: 6)
                        }

                        StyledTextField(label: "Title", text: $title, placeholder: "Enter book title")
                        StyledTextEditor(label: "Description", text: $description)
                        StyledTextField(label: "Filename (auto-set)", text: $filename, disabled: true, placeholder: "Filename auto-generated")

                        StyledPicker(label: "Genre", options: genres, selection: $genre)
                        StyledPicker(label: "JLPT Level", options: levels, selection: $level)

                        TagSection(allTags: allTags, selectedTags: $selectedTags)
                            .padding()
                    }
                    // Remove individual backgrounds here, unified background below

                    if isUploading {
                        ProgressView("Uploading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .softAccent))
                            .padding()
                    } else {
                        Button(action: uploadBook) {
                            Text("Upload Book to Firebase")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient.dustyRoseGradient
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.dustyRose.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                    }

                    if let status = uploadStatus, showStatus {
                        Text(status)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(
                                status.lowercased().contains("success") ? .green : .red
                            )
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.warmBeige.opacity(0.8))
                            .cornerRadius(16)
                            .shadow(color: Color.softAccent.opacity(0.2), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    withAnimation {
                                        showStatus = false
                                    }
                                }
                            }
                    }
                }
                .padding()
                .background(LinearGradient.dustyRoseGradient)
                .cornerRadius(25)
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color.warmBeige.ignoresSafeArea())
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authService)
            }

            
            .toolbarBackground(Color.warmBeige, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.plainText], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                txtFileURL = urls.first
                if let fileName = txtFileURL?.lastPathComponent {
                    filename = fileName
                }
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
            updateStatus("Please select a .txt file", isSuccess: false)
            return
        }
        guard !title.isEmpty else {
            updateStatus("Please enter a title", isSuccess: false)
            return
        }

        isUploading = true
        uploadStatus = nil
        showStatus = false

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let txtRef = storageRef.child("books/\(filename)")

        txtRef.putFile(from: txtFileURL, metadata: nil) { _, error in
            if let error = error {
                updateStatus("Text file upload failed: \(error.localizedDescription)", isSuccess: false)
                isUploading = false
                return
            }

            if let image = coverImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageID = UUID().uuidString
                let imageRef = storageRef.child("covers/\(imageID).jpg")

                imageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        updateStatus("Image upload failed: \(error.localizedDescription)", isSuccess: false)
                        isUploading = false
                        return
                    }

                    imageRef.downloadURL { url, _ in
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

        let data: [String: Any] = [
            "title": title,
            "description": description,
            "filename": filename,
            "genre": genre,
            "level": level,
            "tags": Array(selectedTags),
            "coverImageUrl": coverURL ?? ""
        ]

        docRef.setData(data) { error in
            isUploading = false
            if let error = error {
                updateStatus("Firestore upload failed: \(error.localizedDescription)", isSuccess: false)
            } else {
                updateStatus("✅ Upload successful!", isSuccess: true)
                // Reset form
                title = ""
                description = ""
                filename = ""
                genre = "Other"
                level = "N5"
                selectedTags.removeAll()
                txtFileURL = nil
                coverImage = nil
            }
        }
    }

    func updateStatus(_ message: String, isSuccess: Bool) {
        uploadStatus = message
        withAnimation {
            showStatus = true
        }
    }
}

