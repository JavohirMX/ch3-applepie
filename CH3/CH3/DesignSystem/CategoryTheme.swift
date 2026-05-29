import SwiftUI

struct CategoryTheme {
    let category: CategoryType
    let primary: Color
    let gradientTop: Color
    let gradientBottom: Color
    let iconTint: Color
    let listSubtitle: String
    let watermarkIcon: String

    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [gradientTop, gradientBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func theme(for category: CategoryType) -> CategoryTheme {
        switch category {
        case .transport:
            return CategoryTheme(
                category: .transport,
                primary: Color(red: 0.22, green: 0.55, blue: 0.98),
                gradientTop: Color(red: 0.55, green: 0.78, blue: 1.0),
                gradientBottom: Color(red: 0.22, green: 0.55, blue: 0.98),
                iconTint: Color(red: 0.12, green: 0.38, blue: 0.82),
                listSubtitle: "Past chats related to transport",
                watermarkIcon: "airplane"
            )
        case .store:
            return CategoryTheme(
                category: .store,
                primary: Color(red: 0.20, green: 0.78, blue: 0.42),
                gradientTop: Color(red: 0.72, green: 0.95, blue: 0.55),
                gradientBottom: Color(red: 0.20, green: 0.78, blue: 0.42),
                iconTint: Color(red: 0.10, green: 0.58, blue: 0.28),
                listSubtitle: "Past chats related to store and transactions",
                watermarkIcon: "cart.fill"
            )
        case .hotel:
            return CategoryTheme(
                category: .hotel,
                primary: Color(red: 0.95, green: 0.35, blue: 0.62),
                gradientTop: Color(red: 1.0, green: 0.62, blue: 0.78),
                gradientBottom: Color(red: 0.95, green: 0.35, blue: 0.62),
                iconTint: Color(red: 0.82, green: 0.18, blue: 0.48),
                listSubtitle: "Past chats related to hotels",
                watermarkIcon: "bed.double.fill"
            )
        case .misc:
            return CategoryTheme(
                category: .misc,
                primary: Color(red: 0.98, green: 0.55, blue: 0.18),
                gradientTop: Color(red: 1.0, green: 0.88, blue: 0.45),
                gradientBottom: Color(red: 0.98, green: 0.55, blue: 0.18),
                iconTint: Color(red: 0.88, green: 0.42, blue: 0.08),
                listSubtitle: "Past chats related to anything",
                watermarkIcon: "message.fill"
            )
        }
    }

    static func category(for formType: ContextFormType) -> CategoryType {
        switch formType {
        case .airport, .cab, .bus:
            return .transport
        case .hotel:
            return .hotel
        case .store:
            return .store
        case .miscGeneric:
            return .misc
        }
    }
}
