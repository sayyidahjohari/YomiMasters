import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct AllBooksView: View {
    @StateObject private var viewModel = BooksViewModel()
    @State private var showProfile = false
    @State private var showSignOutConfirmation = false  // Alert trigger

    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @EnvironmentObject var authService: AuthService
    @State private var showingProfileSheet = false  // New: profile sheet flag

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.88)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Text("Library")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showingProfileSheet.toggle()
                            }
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.primary)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                   

                    // Book content
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading books...")
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                ForEach(["N5", "N4", "N3", "N2", "N1"], id: \.self) { level in
                                    if let books = viewModel.booksByLevel[level], !books.isEmpty {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Level \(level)")
                                                .font(.title2)
                                                .bold()
                                                .padding(.horizontal)

                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 20) {
                                                    ForEach(books) { book in
                                                        NavigationLink(destination: BookContentView(filename: book.filename)
                                                            .environmentObject(flashcardViewModel)
                                                        ) {
                                                            VStack(spacing: 8) {
                                                                AsyncImage(url: URL(string: book.coverImageUrl ?? "")) { phase in
                                                                    if let image = phase.image {
                                                                        image
                                                                            .resizable()
                                                                            .scaledToFill()
                                                                    } else {
                                                                        Image("book")
                                                                            .resizable()
                                                                            .scaledToFill()
                                                                    }
                                                                }
                                                                .frame(width: 140, height: 200)
                                                                .cornerRadius(12)
                                                                .clipped()

                                                                Text(book.title)
                                                                    .font(.system(size: 14, weight: .medium))
                                                                    .foregroundColor(.primary)
                                                                    .multilineTextAlignment(.center)
                                                                    .lineLimit(2)
                                                                    .frame(height: 40)
                                                                    .frame(maxWidth: .infinity)
                                                            }
                                                            .padding()
                                                            .frame(width: 160, height: 280)
                                                            .background(Color.white)
                                                            .cornerRadius(16)
                                                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                viewModel.fetchBooks()
            }
            // Show Profile Sheet here
                        .sheet(isPresented: $showingProfileSheet) {
                            ProfileView()
                                .environmentObject(authService)
                        }
                        // Confirmation alert for sign out
                        .alert("Are you sure you want to sign out?", isPresented: $showSignOutConfirmation) {
                            Button("Cancel", role: .cancel) { }
                            Button("Sign Out", role: .destructive) {
                                authService.signOut()
                                withAnimation {
                                    showingProfileSheet = false
                                }
                            }
                        }
                    }
                }
            }

struct FirebaseBooksTestView_Previews: PreviewProvider {
    static var previews: some View {
        AllBooksView()
            .environmentObject(FlashcardViewModel())
            .environmentObject(AuthService())
        
    }
}
