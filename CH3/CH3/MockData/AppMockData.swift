import Foundation

enum AppMockData {
    static let categories: [CategoryCardModel] = [
        CategoryCardModel(type: .transport, title: "Transport", iconSystemName: "airplane", destination: .recentChats(.transport)),
        CategoryCardModel(type: .store, title: "Store", iconSystemName: "cart.fill", destination: .recentChats(.store)),
        CategoryCardModel(type: .hotel, title: "Hotel", iconSystemName: "bed.double.fill", destination: .recentChats(.hotel)),
        CategoryCardModel(type: .misc, title: "Misc", iconSystemName: "message.fill", destination: .recentChats(.misc))
    ]

    static let recentChatsByCategory: [CategoryType: [RecentChat]] = [
        .hotel: [
            RecentChat(category: .hotel, title: "Famous Hotel", subtitle: "Kuta, Bali", dateText: "Jan 7, 2026", countryCode: "ID"),
            RecentChat(category: .hotel, title: "Hyatt Regency", subtitle: "Sanur, Bali", dateText: "Jan 6, 2026", countryCode: "ID"),
            RecentChat(category: .hotel, title: "Kuta Plaza", subtitle: "Kuta, Bali", dateText: "Jan 5, 2026", countryCode: "ID"),
            RecentChat(category: .hotel, title: "Ocean Villa", subtitle: "Uluwatu, Bali", dateText: "Jan 4, 2026", countryCode: "ID")
        ],
        .transport: [
            RecentChat(category: .transport, title: "Trans Metro Dewata", subtitle: "Kuta, Indonesia", dateText: "Jan 7, 2026", countryCode: "ID"),
            RecentChat(category: .transport, title: "Japan Bus Line", subtitle: "Tokyo, Japan", dateText: "Jan 6, 2026", countryCode: "JP"),
            RecentChat(category: .transport, title: "CDG Airport", subtitle: "Paris, France", dateText: "Jan 5, 2026", countryCode: "FR"),
            RecentChat(category: .transport, title: "Sydney Cab", subtitle: "Sydney, Australia", dateText: "Jan 4, 2026", countryCode: "AU")
        ],
        .store: [
            RecentChat(category: .store, title: "Trans Metro Dewata", subtitle: "Kuta, Indonesia", dateText: "Jan 7, 2026", countryCode: "ID"),
            RecentChat(category: .store, title: "Beachwalk Mall", subtitle: "Kuta, Bali", dateText: "Jan 6, 2026", countryCode: "ID"),
            RecentChat(category: .store, title: "Local Market", subtitle: "Ubud, Bali", dateText: "Jan 5, 2026", countryCode: "ID"),
            RecentChat(category: .store, title: "Pharmacy Counter", subtitle: "Denpasar, Bali", dateText: "Jan 4, 2026", countryCode: "ID")
        ],
        .misc: [
            RecentChat(category: .misc, title: "CDG Airport", subtitle: "Paris, France", dateText: "Sep 17, 2023", countryCode: "FR"),
            RecentChat(category: .misc, title: "Japan Bus Line", subtitle: "Tokyo, Japan", dateText: "Aug 12, 2023", countryCode: "JP"),
            RecentChat(category: .misc, title: "Sydney Cab", subtitle: "Sydney, Australia", dateText: "Jul 3, 2023", countryCode: "AU"),
            RecentChat(category: .misc, title: "Tourist Info", subtitle: "Bali, Indonesia", dateText: "Jun 1, 2023", countryCode: "ID")
        ]
    ]

    static let transcriptMessages: [ChatMessage] = {
        let base = Date()
        let calendar = Calendar.current
        return [
            ChatMessage.user("Hi, i'm deaf. Can you speak to my phone please?", timestamp: calendar.date(byAdding: .minute, value: -5, to: base)),
            ChatMessage.other("Sure. What can i help you?", timestamp: calendar.date(byAdding: .minute, value: -4, to: base)),
            ChatMessage.user("Can i have a window seat please?", timestamp: calendar.date(byAdding: .minute, value: -3, to: base)),
            ChatMessage.other("Yes, sure. We have one window seat left", timestamp: calendar.date(byAdding: .minute, value: -2, to: base)),
            ChatMessage.user("Thank you. What is my seat number?", timestamp: calendar.date(byAdding: .minute, value: -1, to: base))
        ]
    }()

    static let transcriptSuggestions: [PhraseSuggestion] = [
        PhraseSuggestion(text: "Perfect. Thank you"),
        PhraseSuggestion(text: "Thank you. What is my seat number?"),
        PhraseSuggestion(text: "Can i get a seat near the toilet?"),
        PhraseSuggestion(text: "Can i bring this suitcase to the cabin?")
    ]

    static func chats(for category: CategoryType) -> [RecentChat] {
        recentChatsByCategory[category] ?? []
    }
}
