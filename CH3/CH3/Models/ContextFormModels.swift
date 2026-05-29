import Foundation

enum ContextFormType: String, Hashable, CaseIterable {
    case airport
    case cab
    case bus
    case hotel
    case store
    case miscGeneric

    var title: String {
        switch self {
        case .airport: return "Flights"
        case .cab: return "Cab / Ride hailing"
        case .bus: return "Bus"
        case .hotel: return "Hotel"
        case .store: return "Store"
        case .miscGeneric: return "Misc"
        }
    }

    var iconSystemName: String {
        switch self {
        case .airport: return "airplane"
        case .cab: return "car.fill"
        case .bus: return "bus.fill"
        case .hotel: return "bed.double.fill"
        case .store: return "cart.fill"
        case .miscGeneric: return "message.fill"
        }
    }
}

enum ContextInputKind {
    case text
    case yesNo
    case dateRange
}

struct ContextFormStep: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let inputKind: ContextInputKind
    let placeholder: String
}

struct ContextFormDefinition: Hashable {
    let formType: ContextFormType
    let steps: [ContextFormStep]
}

struct ContextFormSession: Hashable {
    let formType: ContextFormType
    let answers: [String]

    func makeRecentChat() -> RecentChat {
        let category = CategoryTheme.category(for: formType)
        let theme = CategoryTheme.theme(for: category)
        let title = answers.first?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? (answers.first ?? "New conversation")
            : defaultTitle(for: formType)

        return RecentChat(
            category: category,
            title: title,
            subtitle: defaultSubtitle(for: formType),
            dateText: formattedToday(),
            countryCode: defaultCountryCode(for: formType),
            isNewConversation: true
        )
    }

    private func defaultTitle(for formType: ContextFormType) -> String {
        switch formType {
        case .airport: return "Airport Trip"
        case .cab: return "Cab Ride"
        case .bus: return "Bus Trip"
        case .hotel: return "Hotel Stay"
        case .store: return "Store Visit"
        case .miscGeneric: return "New Chat"
        }
    }

    private func defaultSubtitle(for formType: ContextFormType) -> String {
        switch formType {
        case .airport: return "Airport"
        case .cab: return "Ride hailing"
        case .bus: return "Bus route"
        case .hotel: return "Hotel"
        case .store: return "Shopping"
        case .miscGeneric: return "General"
        }
    }

    private func defaultCountryCode(for formType: ContextFormType) -> String {
        switch formType {
        case .airport: return "FR"
        case .cab: return "AU"
        case .bus: return "JP"
        default: return "ID"
        }
    }

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
}
