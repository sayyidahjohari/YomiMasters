//
//  BookmarkListView.swift
//  YomiMaster
//
//  Created by Sayyidah Nafisah on 16/04/2025.
//


import SwiftUI

struct BookmarkListView: View {
    let bookmarkedPages: [Int]
    let onSelect: (Int) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarkedPages.sorted(), id: \.self) { page in
                    Button(action: {
                        onSelect(page)
                    }) {
                        Text("Page \(page + 1)")
                    }
                }
            }
            .navigationTitle("Bookmarked Pages")
        }
    }
}
