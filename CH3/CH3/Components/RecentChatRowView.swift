import SwiftUI

struct RecentChatRowView: View {
    let chat: RecentChat

    private var theme: CategoryTheme {
        CategoryTheme.theme(for: chat.category)
    }

    var body: some View {
        HStack(spacing: 12) {
            FlagBadgeView(countryCode: chat.countryCode)

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.title)
                    .font(AppTypography.listTitle)
                    .foregroundStyle(.white)
//                Text(chat.subtitle)
//                    .font(AppTypography.body)
//                    .foregroundStyle(.white.opacity(0.95))
                Text(chat.dateText)
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 8)

            Image(systemName: theme.watermarkIcon)
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(.white.opacity(0.22))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(theme.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct FlagBadgeView: View {
    let countryCode: String

    var body: some View {
        Text(FlagEmoji.string(for: countryCode))
            .font(.system(size: 34))
            .frame(width: 48, height: 48)
            .accessibilityLabel(countryCode)
    }
}
