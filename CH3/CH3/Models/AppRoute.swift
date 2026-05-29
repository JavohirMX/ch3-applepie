import Foundation

enum AppRoute: Hashable {
    case recentChats(CategoryType)
    case transportModePicker
    case contextForm(ContextFormType)
    case transcript(RecentChat)
}
