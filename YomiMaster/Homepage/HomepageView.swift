import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct HomepageView: View {
    @StateObject private var viewModel = HomepageViewModel()
    @StateObject private var bookViewModel = BooksViewModel()
    @StateObject private var dailyGoalsVM = DailyGoalsViewModel()
    
    @EnvironmentObject var flashcardViewModel: FlashcardViewModel
    @EnvironmentObject var authService: AuthService
    
    @Binding var isNavBarVisible: Bool // If you want to use it
    
    @State private var userName: String = "Yomi"  // default fallback
    @State private var showSignOutConfirmation = false
    @State private var showingProfileSheet = false
    
    func fetchUserName(uid: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String
                DispatchQueue.main.async {
                    userName = name ?? "Yomi"
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 0.96, green: 0.94, blue: 0.88)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Text("")  // You can put a title if needed
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
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 30) {
                            GreetingView(name: userName)
                            
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
                            
                            // N5 Books Horizontal Scroll
                            if let n5Books = bookViewModel.booksByLevel["N5"], !n5Books.isEmpty {
                                JLPTN5ScrollView(books: n5Books)
                            }
                            
                            DailyGoalsView(viewModel: dailyGoalsVM)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .onAppear {
                bookViewModel.fetchBooks()
                
                if let uid = Auth.auth().currentUser?.uid {
                    fetchUserName(uid: uid)
                }
            }
            .sheet(isPresented: $showingProfileSheet) {
                ProfileView()
                    .environmentObject(authService)
            }
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
