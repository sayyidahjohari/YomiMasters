import SwiftUI
import UIKit

struct SelectableTextViewSimple: UIViewRepresentable {
    let text: String
    var fontSize: CGFloat = 18
    var textColor: UIColor = .label
    var onSelection: ((String) -> Void)?
    @Binding var popupPosition: CGPoint
    @Binding var clearSelectionTrigger: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false

        // Disable autocorrect, prediction, spellcheck etc. if you want
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.autocapitalizationType = .none
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if clearSelectionTrigger {
            DispatchQueue.main.async {
                uiView.selectedTextRange = nil
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableTextViewSimple
        init(_ parent: SelectableTextViewSimple) { self.parent = parent }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard let selectedRange = textView.selectedTextRange,
                  let selectedText = textView.text(in: selectedRange)?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !selectedText.isEmpty else {
                return
            }
            parent.onSelection?(selectedText)

            let rect = textView.firstRect(for: selectedRange)
            var position = CGPoint(x: rect.origin.x, y: rect.origin.y - 50)

            let screenWidth = UIScreen.main.bounds.width
            position.x = max(0, min(screenWidth - 150, position.x))

            DispatchQueue.main.async {
                self.parent.popupPosition = position
            }
        }
    }
}
