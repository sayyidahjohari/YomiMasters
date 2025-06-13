import SwiftUI

struct BookReaderView: View {
    @StateObject var viewModel = BookReaderViewModel()

    var body: some View {
        VStack {
            ScrollView {
                Text(viewModel.currentPage.content)
                    .padding()
                    .font(.system(size: 18))
            }

            HStack {
                Button("Previous") {
                    viewModel.previousPage()
                }
                .disabled(viewModel.currentPageIndex == 0)

                Spacer()

                Text("Page \(viewModel.currentPageIndex + 1)/\(viewModel.pages.count)")

                Spacer()

                Button("Next") {
                    viewModel.nextPage()
                }
                .disabled(viewModel.currentPageIndex == viewModel.pages.count - 1)
            }
            .padding()
        }
        .onAppear {
            viewModel.loadBook(named: "sample_book") // Change to your file name
        }
    }
}
