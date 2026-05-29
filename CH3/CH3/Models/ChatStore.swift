import Foundation
import Observation

@Observable
final class ChatStore {
    var chatsByCategory: [CategoryType: [RecentChat]]

    init() {
        chatsByCategory = AppMockData.recentChatsByCategory
    }

    func chats(for category: CategoryType) -> [RecentChat] {
        chatsByCategory[category] ?? []
    }

    func add(_ chat: RecentChat) {
        var list = chatsByCategory[chat.category] ?? []
        list.insert(chat, at: 0)
        chatsByCategory[chat.category] = list
    }
}
