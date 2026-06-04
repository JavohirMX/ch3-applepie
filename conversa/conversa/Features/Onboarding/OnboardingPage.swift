import Foundation

struct OnboardingPage: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
    let primaryButtonTitle: String
}

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "OnboardingLessStress",
            title: "Less stress",
            subtitle: "An AI-powered travel companion designed for accessible airport journeys.",
            primaryButtonTitle: "Next"
        ),
        OnboardingPage(
            id: 1,
            imageName: "OnboardingPersonalized",
            title: "Make your journey personalized.",
            subtitle: "Your boarding pass helps the app understand where you're going and what you may need during your journey.",
            primaryButtonTitle: "Start"
        ),
    ]
}
