//
//  TodayProgressView.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//


//
//  TodayProgressView.swift
//  Yomi Master
//
//  Created by Sayyidah Nafisah on 29/12/2024.
//

import SwiftUI

struct TodayProgressView: View {
    @StateObject private var viewModel = HomepageViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Progress")
                .font(.title2)
                .fontWeight(.heavy)
                .padding(.horizontal, 20)

            VStack(spacing: 20) {
                ProgressBar(
                    title: "Words Learned",
                    currentValue: viewModel.wordsLearned,
                    totalValue: viewModel.totalWords,
                    progressGradient: LinearGradient(
                        gradient: Gradient(colors: [.darkBlue, .notSoHotPink]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    icon: "text.book.closed"
                )
                ProgressBar(
                    title: "Pages Read",
                    currentValue: viewModel.pagesRead,
                    totalValue: viewModel.totalPages,
                    progressGradient: LinearGradient(
                        gradient: Gradient(colors: [.darkBlue, .notSoHotPink]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    icon: "book"
                )
                ProgressBar(
                    title: "Flashcards Reviewed",
                    currentValue: viewModel.flashcardsReviewed,
                    totalValue: viewModel.totalFlashcards,
                    progressGradient: LinearGradient(
                        gradient: Gradient(colors: [.darkBlue, .notSoHotPink]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    icon: "rectangle.stack.fill"
                )
            }
            .padding(.horizontal, 20)
        }
    }
}
