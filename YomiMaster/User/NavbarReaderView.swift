import SwiftUI

struct NavbarReaderView: View {
    @State private var isNavBarReaderVisible = true
    @State private var isBottomBarVisible = true

    @Binding var isNavBarVisible: Bool
    @Binding var showPopup: Bool  // ✅ Add this

    var body: some View {
        VStack(spacing: 0) {
            if isNavBarReaderVisible {
                HStack {
                    Text("Adventure in the Forest")
                        .font(.title)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.clear)
            }

            BookReaderView(showDefinition: $showPopup)  // ✅ Pass binding down
                .padding(.horizontal)
                .allowsHitTesting(!showPopup)  // ✅ Prevent interaction behind popup
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            withAnimation { isNavBarVisible = false }
        }
        .onDisappear {
            withAnimation { isNavBarVisible = true }
        }
        .onTapGesture {
            if !showPopup {  // ✅ Prevent hiding/showing UI when popup is shown
                withAnimation {
                    isNavBarReaderVisible.toggle()
                    isBottomBarVisible.toggle()
                }
            }
        }
    }
}


struct NavbarReaderView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper2((true, false)) { isNavBarVisible, showPopup in
            NavbarReaderView(isNavBarVisible: isNavBarVisible, showPopup: showPopup)
                .environmentObject(FlashcardViewModel())
                
        }
    }
}
