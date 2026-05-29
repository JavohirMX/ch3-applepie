import Foundation

enum CategoryType: String, CaseIterable, Identifiable, Hashable {
    case transport = "Transport"
    case store = "Store"
    case hotel = "Hotel"
    case misc = "Misc"

    var id: String { rawValue }
}

struct CategoryCardModel: Identifiable, Hashable {
    let id = UUID()
    let type: CategoryType
    let title: String
    let iconSystemName: String
    let destination: AppRoute
}

struct RecentChat: Identifiable, Hashable {
    let id: UUID
    let category: CategoryType
    let title: String
    let subtitle: String
    let dateText: String
    let countryCode: String
    var isNewConversation: Bool

    init(
        id: UUID = UUID(),
        category: CategoryType,
        title: String,
        subtitle: String,
        dateText: String,
        countryCode: String = "ID",
        isNewConversation: Bool = false
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.dateText = dateText
        self.countryCode = countryCode
        self.isNewConversation = isNewConversation
    }
}

struct PhraseSuggestion: Identifiable, Hashable {
    let id = UUID()
    let text: String
}
