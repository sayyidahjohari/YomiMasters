import SwiftUI

struct ReadingView: View {
    @State private var showPopup = false
    @State private var selectedWord = ""
    @State private var sentenceContext = "森を歩いていました。" // Example sentence
    
    var body: some View {
        ZStack {
            // Reading Text
            VStack(alignment: .leading, spacing: 10) {
                HStack{
                    Spacer()
                Text("Adventure in the Forest")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    Spacer()
            }
                
                Text(sentenceContext)
                    .lineSpacing(5)
                    .font(.system(size: 18))
                    .onTapGesture {
                        // Simulating word selection for demo
                        selectedWord = "歩いて" // Example word "aruite"
                        showPopup = true
                    }
                    .padding([.top, .leading, .trailing])
                Text("少年はさらに森の奥へ進むと、小さな湖が姿を現しました。湖面は鏡のように静かで、青空と周囲の木々を美しく映し出しています。水辺に座り込んだ少年は、湖の中に泳ぐ小さな魚たちをじっと見つめました。その瞬間、彼は風が運んできた何かの香りに気づきました。それは甘く、どこか懐かしい香りでした。「この先に何かあるのかな？」とつぶやきながら、少年は立ち上がり、湖の向こうへ 歩いて行きました。道の途中、彼は苔むした岩の上に奇妙な模様が彫られているのを見つけました。その模様は、何かの文字のようにも見えましたが、少年には解読することができません。さらに進むと、開けた草原にたどり着きました。草原には色とりどりの花が咲き誇り、風に揺れるその光景はまるで絵画のようでした。少年は花の中に一つだけ、他とは違う金色に輝く花を見つけました。その花を摘むと、突然周囲の景色が少しずつ変わり始めました。「あれ？」少年は驚き、周りを見渡しました。草原は消え、代わりに石造りの大きな門が現れました。門には「ここから先は試練の地」という言葉が彫られており、その文字は金色の光を放っています。少年は立ち止まり、少し不安げにその門を見上げました。しかし、心の中ではなぜか「進まなければならない」という気持ちが湧き上がっていました。")
                    .lineSpacing(5)
                    .font(.system(size: 18))
                    .padding(.horizontal)
                
                Spacer()
            }
            .
            padding(.horizontal)
            
            // Colorful Popup
            if showPopup {
                PopupView(
                    selectedWord: selectedWord,
                    sentenceContext: sentenceContext,
                    showPopup: $showPopup
                )
            }
        }
    }
}

struct PopupView: View {
    let selectedWord: String
    let sentenceContext: String
    @Binding var showPopup: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Title with Gradient Background
            Text(selectedWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                                           // Color("soft green"),
                                            Color("soft green")
                                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            
            // Word Details
            VStack(alignment: .leading, spacing: 15) {
                
                // Meaning Section
                SectionTitle(title: "Meaning", color: .blue)
                Text("To walk (歩いて is the te-form of 歩く, meaning 'walk').") // Example meaning
                
                // Context Section
                SectionTitle(title: "Context in Sentence", color: .purple)
                Text("The phrase \(selectedWord) means 'walking' as part of the sentence '\(sentenceContext)', describing someone walking in a forest.")
                
                // Grammar Section
                SectionTitle(title: "Grammar", color: .green)
                Text("Te-form is often used to connect actions or for progressive tense, e.g., 'walking' here.")
                
                // Reading Section
                SectionTitle(title: "Reading (Furigana)", color: .orange)
                Text("あるいて (Aruite)")
                
                // Example Usage Section
                SectionTitle(title: "Example Usage", color: .red)
                Text("彼は毎日学校まで歩いています。 (He walks to school every day.)")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
            
            Button(action: {
                print("Added \(selectedWord) to flashcard")
                showPopup = false
            }) {
                Text("Add to Flashcard")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                               // Color("soft green"),
                                                Color("soft green")
                                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }

            
            // Close Button
            Button(action: {
                showPopup = false
            }) {
                Text("Close")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 30)
        .transition(.move(edge: .bottom))
        .animation(.spring(), value: showPopup)
    }
}

struct SectionTitle: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(color)
            .padding(.bottom, 2)
            .underline()
    }
}

struct ContentView: View {
    var body: some View {
        ReadingView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
