import Foundation
import Observation

@Observable
final class ChatStore {
    var chatsByCategory: [CategoryType: [RecentChat]] = [:]
    var isLoading = false
    var errorMessage: String?

    init() {
        chatsByCategory = AppMockData.recentChatsByCategory
    }

    // MARK: - Read

    func chats(for category: CategoryType) -> [RecentChat] {
        chatsByCategory[category] ?? []
    }

    // MARK: - Load from backend

    /// Load chats from the backend for a specific category.
    @MainActor
    func loadChats(for category: CategoryType) async {
        isLoading = true
        errorMessage = nil

        do {
            let items = try await ChatService.shared.listChats(category: category.apiValue)
            let chats = items.map { RecentChat(from: $0) }
            chatsByCategory[category] = chats
        } catch {
            errorMessage = error.localizedDescription
            // Keep existing cached data on failure
        }

        isLoading = false
    }

    /// Load all chats across all categories.
    @MainActor
    func loadAllChats() async {
        isLoading = true
        errorMessage = nil

        do {
            let items = try await ChatService.shared.listChats()
            let grouped = Dictionary(grouping: items, by: { CategoryType(fromApiValue: $0.category) })
            var result: [CategoryType: [RecentChat]] = [:]
            for (category, items) in grouped {
                result[category] = items.map { RecentChat(from: $0) }
            }
            chatsByCategory = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Create (backend)

    /// Create a chat on the backend and insert it locally.
    @MainActor
    func createChat(
        category: CategoryType,
        formType: ContextFormType,
        title: String,
        subtitle: String?,
        countryCode: String,
        contextAnswers: [String: String]
    ) async throws -> RecentChat {
        let response = try await ChatService.shared.createChat(
            category: category.apiValue,
            formType: formType.apiValue,
            title: title,
            subtitle: subtitle,
            countryCode: countryCode,
            contextAnswers: contextAnswers
        )
        let chat = RecentChat(from: response)
        add(chat)
        return chat
    }

    // MARK: - Local mutation

    func add(_ chat: RecentChat) {
        var list = chatsByCategory[chat.category] ?? []
        list.insert(chat, at: 0)
        chatsByCategory[chat.category] = list
    }

    // MARK: - Delete

    @MainActor
    func deleteChat(_ chat: RecentChat) async {
        do {
            try await ChatService.shared.deleteChat(chatId: chat.id.uuidString)
            var list = chatsByCategory[chat.category] ?? []
            list.removeAll { $0.id == chat.id }
            chatsByCategory[chat.category] = list
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - DTO → Model mapping

extension RecentChat {
    init(from item: ChatListItem) {
        self.init(
            id: UUID(uuidString: item.id) ?? UUID(),
            category: CategoryType(fromApiValue: item.category),
            title: item.title,
            subtitle: item.subtitle ?? "",
            dateText: RecentChat.formatDate(item.createdAt),
            countryCode: item.countryCode,
            isNewConversation: false
        )
    }

    init(from response: ChatResponse) {
        self.init(
            id: UUID(uuidString: response.id) ?? UUID(),
            category: CategoryType(fromApiValue: response.category),
            title: response.title,
            subtitle: response.subtitle ?? "",
            dateText: RecentChat.formatDate(response.createdAt),
            countryCode: response.countryCode,
            isNewConversation: true
        )
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - API string ↔ enum helpers

extension CategoryType {
    /// Lowercase string for the backend API.
    var apiValue: String {
        rawValue.lowercased()
    }

    /// Create from a backend category string.
    init(fromApiValue value: String) {
        switch value.lowercased() {
        case "transport": self = .transport
        case "store": self = .store
        case "hotel": self = .hotel
        default: self = .misc
        }
    }
}

extension ContextFormType {
    /// Snake_case string for the backend API.
    var apiValue: String {
        switch self {
        case .airport: return "airport"
        case .cab: return "cab"
        case .bus: return "bus"
        case .hotel: return "hotel"
        case .store: return "store"
        case .miscGeneric: return "misc_generic"
        }
    }
}
