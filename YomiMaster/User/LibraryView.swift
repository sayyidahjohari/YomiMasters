//
//  LibraryView.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//


//
//  LibraryView.swift
//  Yomi Master
//
//  Created by Sayyidah Nafisah on 30/12/2024.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var viewModel = HomepageViewModel()
    @State private var isNavBarVisible = true // Add a state variable for navbar visibility
    @State private var showPopup: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("soft pink") // Soft beige/cream
                            .opacity(0.6),//
                        Color(.blue)
                            .opacity(0.1),//
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                ScrollView{
                    
                    VStack{
                       
                        HStack{ //library's title
                            Spacer()
                            Text("Library")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        .padding([.top, .leading, .bottom], 20.0)
                        
                        TextField("Search...", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                        
                        NavigationLink(destination: NavbarReaderView(isNavBarVisible: $isNavBarVisible, showPopup: $showPopup)) {
                            RecentReadsView(isNavBarVisible: $isNavBarVisible, books: viewModel.books)
                                .padding(.vertical)
                        }
                        
                        .foregroundColor(.black)
                        
                        NavigationLink(destination: NavbarReaderView(isNavBarVisible: $isNavBarVisible, showPopup: $showPopup)) {
                            RecommendedBookView(books: viewModel.books)
                                .padding(.vertical)
                        }.foregroundColor(.black)
                        
                        NavigationLink(destination: NavbarReaderView(isNavBarVisible: $isNavBarVisible, showPopup: $showPopup)) {
                            WantToReadView(books: viewModel.books)
                                .padding(.vertical)
                        }.foregroundColor(.black)
                        
                        Spacer()
                    }
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    LibraryView()
}
//
