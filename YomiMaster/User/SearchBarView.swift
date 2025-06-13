//
//  SearchBarView.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//


//
//  SearchBarView.swift
//  Yomi Master
//
//  Created by Sayyidah Nafisah on 30/12/2024.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""

    var body: some View {
        HStack {
            TextField("Search...", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Spacer()
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                )
        }
    }
}
