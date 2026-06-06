import SwiftUI

struct TranscriptionPlaceholderView: View {
    var body: some View {
        Text("I am deaf, I use this device to communicate with you.\n\nSay what you want to say to me now.")
            .font(Typography.transcriptPlaceholder)
            .foregroundStyle(BrandColors.transcriptPlaceholder)
            .multilineTextAlignment(.leading)
            .lineSpacing(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    TranscriptionPlaceholderView()
        .padding(.horizontal, 24)
        .frame(width: 390, height: 700, alignment: .topLeading)
        .background(Color.white)
}
