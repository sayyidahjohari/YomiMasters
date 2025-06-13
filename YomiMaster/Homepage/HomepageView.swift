import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct HomepageView: View {
    @StateObject private var viewModel = HomepageViewModel()
    @StateObject private var bookViewModel = BooksViewModel()
    @State private var showProfile = false
    @State private var showSignOutConfirmation = false
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @EnvironmentObject var authService: AuthService
    @Binding var isNavBarVisible: Bool
    @State private var showPopup: Bool = false
    @ObservedObject var checklistVM: ChecklistViewModel


    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 0.96, green: 0.94, blue: 0.88)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Text("")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showProfile.toggle()
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

                    ScrollView(.vertical) {
                        VStack(spacing: 30) {
                            GreetingView(email: authService.user?.email)

                            HStack {
                                Text(viewModel.streakMessage)
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .padding(.horizontal, 20)

                            TextField("Search...", text: $viewModel.searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 20)

                            // ✅ N5 Books Horizontal Scroll
                            if let n5Books = bookViewModel.booksByLevel["N5"], !n5Books.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("JLPT N5 Picks")
                                        .font(.title2)
                                        .bold()
                                        .padding(.horizontal, 20)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(n5Books) { book in
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
                                                        .frame(width: 120, height: 170)
                                                        .cornerRadius(12)
                                                        .clipped()

                                                        Text(book.title)
                                                            .font(.caption)
                                                            .foregroundColor(.primary)
                                                            .multilineTextAlignment(.center)
                                                            .lineLimit(2)
                                                            .frame(height: 40)
                                                    }
                                                    .frame(width: 140)
                                                    .padding(8)
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .shadow(radius: 3)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }

                            WordOfTheDayView(word: "森 (もり)", meaning: "Forest")
                                .padding(.horizontal, 20)

                            // 🔜 Insert ChecklistView here in your actual project
                            ChecklistView(viewModel: checklistVM)

                            TodayProgressView()
                                .padding(.bottom, 80)
                        }
                        .padding(.top, 10)
                    }
                }

                // Profile Popup
                if showProfile {
                    VStack(alignment: .leading, spacing: 16) {
                        if let user = authService.user {
                            Text("Email: \(user.email ?? "Unknown")")
                            Text("Role: \(authService.role ?? "Unknown")")
                        }

                        Button(role: .destructive) {
                            showSignOutConfirmation = true
                        } label: {
                            Text("Sign Out")
                                .bold()
                        }

                        Button("Close") {
                            withAnimation {
                                showProfile = false
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .frame(width: 250)
                    .padding(.leading)
                    .padding(.top, 60)
                    .transition(.move(edge: .top))
                }
            }
            .onAppear {
                bookViewModel.fetchBooks()
            }
            .alert("Are you sure you want to sign out?", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                    withAnimation {
                        showProfile = false
                    }
                }
            }
        }
    }
}

struct HomepageView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { isVisible in
            HomepageView(
                isNavBarVisible: isVisible,
                checklistVM: ChecklistViewModel()
            )
            .environmentObject(FlashcardViewModel())
            .environmentObject(AuthService())
        }
    }
}
