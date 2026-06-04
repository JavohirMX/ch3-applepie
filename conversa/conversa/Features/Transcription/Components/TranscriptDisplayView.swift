import SwiftUI

struct TranscriptDisplayView: View {
    let text: String
    var textColor: Color = BrandColors.navy

    var body: some View {
        ScrollView {
            Text(text)
                .font(Typography.transcriptBody)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.visible)
    }
}

#Preview {
    TranscriptDisplayView(text: "I need help finding gate 5.")
        .frame(height: 200)
        .padding()
}
