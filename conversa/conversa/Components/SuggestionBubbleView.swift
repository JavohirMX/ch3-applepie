import SwiftUI

enum SuggestionBubbleStyle {
    case compact
    case standard
}

struct SuggestionBubbleView: View {
    let text: String
    var style: SuggestionBubbleStyle = .standard
    let onTap: () -> Void

    private var backgroundColor: Color {
        switch style {
        case .compact: BrandColors.compactSuggestionBackground
        case .standard: .white
        }
    }

    private var borderOpacity: Double {
        style == .compact ? 0.15 : 0.25
    }

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(Typography.suggestionBody)
                .foregroundStyle(BrandColors.navy)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BrandColors.navy.opacity(borderOpacity), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
    }
}

#Preview {
    SuggestionBubbleView(text: "I need help finding gate 5.", onTap: {})
        .padding()
}
