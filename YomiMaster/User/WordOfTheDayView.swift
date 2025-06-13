//
//  WordOfTheDayView.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//


//
//  WordOfTheDayView.swift
//  Yomi Master
//
//  Created by Sayyidah Nafisah on 29/12/2024.
//

import SwiftUI
struct WordOfTheDayView: View {
    var word: String
    var meaning: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Word of the Day")
                .font(.title2)
                .fontWeight(.heavy)
            Text("\(word) - \(meaning)")
                .font(.title3)
                .foregroundColor(.primary)
                .italic()
        }
        .padding(.horizontal, 20)
    }
}
