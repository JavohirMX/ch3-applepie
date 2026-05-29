import SwiftUI

enum AppColors {
    static let background = Color(.systemGray6)
    static let textPrimary = Color.black.opacity(0.88)
    static let textSecondary = Color.black.opacity(0.52)
    /// iMessage-style incoming bubble gray (#E5E5EA).
    static let incomingBubble = Color(red: 0.898, green: 0.898, blue: 0.918)
    /// iMessage-style sent bubble blue (#007AFF).
    static let userBubble = Color(red: 0.0, green: 0.478, blue: 1.0)

    static func cardColor(for category: CategoryType) -> Color {
        CategoryTheme.theme(for: category).primary
    }

    static func iconColor(for category: CategoryType) -> Color {
        CategoryTheme.theme(for: category).iconTint
    }
}
