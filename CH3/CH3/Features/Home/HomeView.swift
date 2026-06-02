import SwiftUI

// for now the button will be bordered style
// for now, it's very messy but I'm aiming for an MVP
struct HomeView: View {
    let categories: [CategoryCardModel]
    
    @FocusState private var isFocused: Bool
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var micIsActive = false
    @State private var lastSpokenText: String?
    
    // body
    var body: some View {
        NavigationStack{
            ZStack{
                // for background later
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .top) {
                        NavigationLink(){
                            PastChatsView()
                        } label : {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 21))
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "microphone.fill")
                                .font(.system(size: 32))
                                .frame(width: 60, height: 60)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 21))
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                    }
                    Spacer()
                    // if empty
                    VStack(){
                        VStack(alignment:.leading, spacing:20){
                            Button{
                                appendMessage(.user("Hello, I'm deaf or hard of hearing. I use this tool to communicate with you."))
                            } label:{
                                Label("Hello, I'm deaf or hard of hearing. I use this tool to communicate with you.", systemImage: "bubble")
                                    .multilineTextAlignment(.leading)
                            }
                            Button{} label:{
                                Label("How much does this cost?", systemImage: "bubble")
                                    .multilineTextAlignment(.leading)
                            }
                            Button{} label:{
                                Label("Hello, I need help with directions", systemImage: "bubble")
                                    .multilineTextAlignment(.leading)
                            }
                            Button{} label:{
                                Label("I'd like to check in, please.", systemImage: "bubble")
                                    .multilineTextAlignment(.leading)
                            }
                        }.padding()
                            .padding(.bottom, 32)
                        
                        HStack(spacing:2){
                            Menu {
                                Picker(selection: .constant(1), content: {
                                    Label("Transactions", systemImage: "cart.fill")
                                        .tag(4)
                                    Label("Stay", systemImage: "bed.double.fill")
                                        .tag(3)
                                    Label("Transportation", systemImage: "airplane")
                                        .tag(2)
                                    Label("General Chat", systemImage: "bubble.left.and.bubble.right.fill")
                                        .tag(1)
                                }, label: {
                                    Text("Picker")
                                })
                            } label: {
                                // HIG IS 44 FOR BUTTON SIZE BUT ITS TOO SMALL IF I PUT IT HERE?
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 17))
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.glassProminent)
                            .buttonBorderShape(.circle)
                            ZStack(alignment: .trailing){
                                TextField("Say something", text: $inputText)
                                    .focused($isFocused)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 13)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 99))
                                Button(){
                                    
                                } label : {
                                    Image(systemName: "paperplane.fill")
                                }
                                .padding(.horizontal, 15)
                            }
                            Button{}label:{
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                    .font(.system(size: 21))
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.circle)
                        }
                    }
                    .padding(.bottom, 12)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFocused = true
                    }
                }
                .background(Color.white.ignoresSafeArea())
            }
        }
    }
    // functions needed
    
    private func bubbleTransition(for message: ChatMessage) -> AnyTransition {
        switch message.sender {
        case .user:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .opacity
            )
        case .other:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .opacity
            )
        case .system:
            return .opacity
        }
    }
    
    private func appendMessage(_ message: ChatMessage) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            messages.append(message)
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        appendMessage(.user(trimmed))
        inputText = ""
    }

    private func speakMessage(_ text: String) {
        lastSpokenText = text
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundStyle(Color(.systemGray2))
            Text("You can now start the conversation")
                .font(AppTypography.body)
                .foregroundStyle(Color(.systemGray5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

}

#Preview {
    ContentView()
}

