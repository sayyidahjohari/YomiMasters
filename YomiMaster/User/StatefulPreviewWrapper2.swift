import SwiftUI

struct StatefulPreviewWrapper2<Content: View>: View {
    @State private var value1: Bool
    @State private var value2: Bool
    let content: (Binding<Bool>, Binding<Bool>) -> Content

    init(_ initialValues: (Bool, Bool), @ViewBuilder content: @escaping (Binding<Bool>, Binding<Bool>) -> Content) {
        self._value1 = State(initialValue: initialValues.0)
        self._value2 = State(initialValue: initialValues.1)
        self.content = content
    }

    var body: some View {
        content($value1, $value2)
    }
}
