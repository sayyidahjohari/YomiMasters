import SwiftUI

struct FuriganaPreviewView: View {
    let textWithFurigana: String

    var body: some View {
        VStack {
            let furiganaWords = parseFurigana(from: textWithFurigana)

            ForEach(furiganaWords, id: \.kanji) { word in
                Text(word.kanji)
                    .font(.title)
                    .overlay(
                        Text(word.furigana)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .offset(y: -20), alignment: .top
                    )
            }
        }
        .padding()
    }
}

struct FuriganaPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        FuriganaPreviewView(textWithFurigana: "森《もり》を歩《ある》いていました。")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
