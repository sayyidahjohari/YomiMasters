import SwiftUI
import UIKit
import NaturalLanguage

import SwiftUI
import UIKit

struct SelectableTextView: UIViewRepresentable {
    let text: String
    var fontSize: CGFloat = 18
    var textColor: UIColor = .label
    var isEditable: Bool = false
    var onSelection: ((String) -> Void)?
    @Binding var clearSelectionTrigger: Bool
    @Binding var popupPosition: CGPoint
    @Binding var highlightedWords: Set<HighlightedWord>
    let currentPage: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = CustomTextView()
        textView.delegate = context.coordinator
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.inputAssistantItem.leadingBarButtonGroups = []
        textView.inputAssistantItem.trailingBarButtonGroups = []
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let attributedText = NSMutableAttributedString(string: text)

        // Set base font and color
        let fullRange = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: fullRange)
        attributedText.addAttribute(.foregroundColor, value: textColor, range: fullRange)

        // ✅ Highlight full word/phrase matches from highlightedWords
        for highlighted in highlightedWords where highlighted.page == currentPage {
            let searchString = highlighted.word
            var searchStartIndex = text.startIndex

            while searchStartIndex < text.endIndex,
                  let range = text.range(of: searchString, range: searchStartIndex..<text.endIndex) {

                let nsRange = NSRange(range, in: text)
                attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: nsRange)

                searchStartIndex = range.upperBound
            }
        }


        uiView.attributedText = attributedText

        DispatchQueue.main.async {
            if self.clearSelectionTrigger {
                uiView.selectedTextRange = nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableTextView
        var wordCounts: [String: Int] = [:]

        init(_ parent: SelectableTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let range = textView.selectedTextRange else { return }
            let selectedText = textView.text(in: range) ?? ""
            let cleanText = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)

            if !cleanText.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let count = (self.wordCounts[cleanText] ?? 0) + 1
                    self.wordCounts[cleanText] = count

                    let newWord = HighlightedWord(
                        word: cleanText,
                        page: self.parent.currentPage,
                        indexInPage: count
                    )

                    self.parent.onSelection?(cleanText)

                    if let selectedRange = textView.selectedTextRange {
                        let rect = textView.firstRect(for: selectedRange)
                        var position = CGPoint(x: rect.origin.x, y: rect.origin.y - 50)
                        let screenWidth = UIScreen.main.bounds.width
                        position.x = max(0, min(screenWidth - 150, position.x))
                        self.parent.popupPosition = position
                    }
                }
            }
        }
    }
}

class CustomTextView: UITextView {
    var onSelection: ((String) -> Void)?

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false // Disable default copy/paste menu
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let selectedTextRange = self.selectedTextRange {
            let selectedText = self.text(in: selectedTextRange) ?? ""
            if !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                onSelection?(selectedText)
            }
        }
    }
}

