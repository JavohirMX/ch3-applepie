import SwiftUI

/// Full-screen message display rotated 180° for the other person to read.
struct FlipTextView: View {
    let text: String
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            FittingText(
                text: text,
                minFontSize: 28,
                maxFontSize: 120,
                fontWeight: .semibold,
                uiFontWeight: .semibold
            )
            .rotationEffect(.degrees(180))
            .onTapGesture(perform: onDismiss)
            .accessibilityLabel("Message for the other person to read")

            VStack {
                HStack {
                    Spacer()
                    closeButton
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.top, 8)
        }
    }

    private var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(BrandColors.navy)
                .frame(width: 44, height: 44)
                .background(BrandColors.actionButtonBackground, in: Circle())
        }
        .accessibilityLabel("Close")
    }
}

#Preview {
    FlipTextView(
        text: "Hi there, my name is Leo and I am deaf. I use this app to communicate with you.",
        onDismiss: {}
    )
}
