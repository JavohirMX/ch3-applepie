import SwiftUI

struct TranscriptionBackButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Back")
    }
}

#Preview {
    TranscriptionBackButton()
        .padding()
        .background(
            LinearGradient(
                colors: [BrandColors.listeningGradientTop, BrandColors.listeningGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
}
