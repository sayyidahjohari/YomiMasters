import SwiftUI

struct TagSection: View {
    let allTags: [String]
    @Binding var selectedTags: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.black)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(allTags, id: \.self) { tag in
                    TagCheckbox(tag: tag, isSelected: selectedTags.contains(tag)) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                }
            }
        }
        .padding()
        .background(LinearGradient.dustyRoseGradient)
        .cornerRadius(16)
        .shadow(color: Color.softAccent.opacity(0.15), radius: 6, x: 0, y: 4)
    }
}
