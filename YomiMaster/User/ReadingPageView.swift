//
//  ReadingPageView.swift
//  YM
//
//  Created by Sayyidah Nafisah on 31/12/2024.
//


import SwiftUI

struct ReadingPageView: View {
    // Sample book pages (replace with your dynamic content or data source)
    @State private var pages = [
        "This is the first page of the book. You can swipe to navigate.",
        "This is the second page of the book. Highlight words to interact.",
        "This is the third page. Happy reading!"
    ]

    @State private var currentPage = 0
    @State private var selectedText: String = ""
    @State private var showPopup = false
    
    var body: some View {
        ZStack {
            // Page content
            Text(pages[currentPage])
                .padding()
                .font(.body)
                .multilineTextAlignment(.leading)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            // Handle swipe left or right
                            if value.translation.width < -50, currentPage < pages.count - 1 {
                                currentPage += 1
                            } else if value.translation.width > 50, currentPage > 0 {
                                currentPage -= 1
                            }
                        }
                )
                .onTapGesture {
                    // Simulate text selection for demo purposes
                    selectedText = "Selected Text"
                    showPopup = true
                }
                .padding(.horizontal, 20)

            // Popup options for selected text
            if showPopup {
                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: {
                            // Handle highlighting logic here
                            print("Highlight: \(selectedText)")
                            showPopup = false
                        }) {
                            Text("Highlight")
                                .padding()
                                .background(Color.yellow.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            // Handle adding to flashcard logic here
                            print("Add to Flashcard: \(selectedText)")
                            showPopup = false
                        }) {
                            Text("Add to Flashcard")
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            // Handle lookup logic here
                            print("Lookup: \(selectedText)")
                            showPopup = false
                        }) {
                            Text("Lookup")
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct ReadingPageView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingPageView()
    }
}
