import SwiftUI

/// iOS 26 Liquid Glass message composer (iMessage-style capsule).
struct MessageGlassInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    let theme: CategoryTheme
    
    private let sendButtonSize: CGFloat = 28

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        GlassEffectContainer {
            HStack(alignment: .center, spacing: 8) {
                TextField("What do you want to say?", text: $text, axis: .vertical)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .lineLimit(1...4)
                    .textFieldStyle(.plain)
                    .submitLabel(.send)
                    .onSubmit(onSend)
                    .frame(minHeight: 22, maxHeight: 88, alignment: .center)

                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: sendButtonSize, height: sendButtonSize)
                        .background(canSend ? theme.primary : Color(.systemGray3))
                        .clipShape(Circle())
                }
                .disabled(!canSend)
                .buttonStyle(.plain)
            }
            .frame(minHeight: sendButtonSize)
            .padding(.leading, 14)
            .padding(.trailing, 8)
            .padding(.vertical, 6)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }
}
