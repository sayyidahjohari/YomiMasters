import SwiftUI
import UIKit

struct SelectableTextView: UIViewRepresentable {
    let text: String
    var font: UIFont = UIFont.systemFont(ofSize: 18)
    var textColor: UIColor = .label
    var isEditable: Bool = false
    var onSelection: ((String) -> Void)? // This will pass selected text back to SwiftUI

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.font = font
        textView.textColor = textColor
        textView.text = text

        // Remove padding
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableTextView

        init(_ parent: SelectableTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let range = textView.selectedTextRange else { return }
            let selectedText = textView.text(in: range) ?? ""
            if !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parent.onSelection?(selectedText)
            }
        }
    }
}
