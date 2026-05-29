import SwiftUI

struct SuggestionPillStyle: ViewModifier {
    let theme: CategoryTheme

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(theme.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(theme.primary.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func suggestionPill(theme: CategoryTheme) -> some View {
        modifier(SuggestionPillStyle(theme: theme))
    }
}
