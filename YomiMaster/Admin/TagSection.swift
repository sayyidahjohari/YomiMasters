import SwiftUI
extension Color {
    static let dustyRose = Color(red: 188/255, green: 113/255, blue: 124/255)  // dusty rose tone
}

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
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.softAccent.opacity(0.15), radius: 6, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.dustyRose.opacity(0.8), lineWidth: 1)
        )
    }
}

struct TagCheckbox: View {
    let tag: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Text(tag)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(isSelected ? Color.white.opacity(0.85) : Color.white)
                .foregroundColor(isSelected ? .dustyRose : Color.black)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.dustyRose.opacity(isSelected ? 0.85 : 0.7), lineWidth: 1.5)
                )
                .shadow(color: isSelected ? Color.dustyRose.opacity(0.25) : Color.clear, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        
    }
}
