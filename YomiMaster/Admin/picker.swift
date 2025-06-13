import Foundation
import SwiftUI
extension Color {
    static let softAccent = Color(red: 0.68, green: 0.64, blue: 0.60)
    static let warmBeige = Color(red: 0.98, green: 0.96, blue: 0.93)
    static let lightGrayText = Color(red: 0.35, green: 0.35, blue: 0.38)
}

extension LinearGradient {
    static let dustyRoseGradient = LinearGradient(
        colors: [
            Color(red: 0.78, green: 0.64, blue: 0.66).opacity(0.9),
            Color(red: 0.98, green: 0.96, blue: 0.93).opacity(0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
struct StyledTextField: View {
    let label: String
    @Binding var text: String
    var disabled: Bool = false
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            TextField(placeholder, text: $text)
                .disabled(disabled)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dustyRose.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: Color.softAccent.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
}

struct StyledTextEditor: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)
            TextEditor(text: $text)
                .frame(height: 120)
                .padding(8)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dustyRose.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: Color.softAccent.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
}

struct UploadPicker: View {
    let label: String
    let icon: String
    let selectedText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.dustyRose)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(selectedText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.softAccent.opacity(0.15), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.dustyRose.opacity(0.8), lineWidth: 1)
            )
            
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}



struct StyledPicker: View {
    let label: String
        let options: [String]
        @Binding var selection: String
        @State private var isExpanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.black)

                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selection.isEmpty ? "Select \(label.lowercased())" : selection)
                            .foregroundColor(selection.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.dustyRose)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.dustyRose.opacity(0.8), lineWidth: 1)
                    )
                    .shadow(color: Color.dustyRose.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selection = option
                                withAnimation {
                                    isExpanded = false
                                }
                            }) {
                                Text(option)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(selection == option ? Color.dustyRose.opacity(0.2) : Color.clear)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.dustyRose.opacity(0.2), radius: 6, x: 0, y: 3)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal)
        }
    }

