//
//  RecommendedBookView.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//

import SwiftUI


struct RecommendedBookView: View {
    // User Data
    @StateObject private var viewModel = HomepageViewModel()
    
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recommended Book")
                .font(.title2)
                .fontWeight(.heavy)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(books) { book in
                        VStack {
                            Image(book.cover)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 200)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            Text(book.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                        }
                        .frame(width: 160)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
