// JLPTN5ScrollView.swift
struct JLPTN5ScrollView: View {
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("JLPT N5 Picks")
                .font(.title2)
                .bold()
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(books) { book in
                        NavigationLink(destination: BookContentView(filename: book.filename)) {
                            VStack(spacing: 8) {
                                AsyncImage(url: URL(string: book.coverImageUrl ?? "")) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image("book")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                                .frame(width: 120, height: 170)
                                .cornerRadius(12)
                                .clipped()

                                Text(book.title)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(height: 40)
                            }
                            .frame(width: 140)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
