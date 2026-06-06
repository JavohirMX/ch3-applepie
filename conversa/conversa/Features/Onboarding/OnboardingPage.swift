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
            imageName: "Onboard1 Finish",
            title: "Understand every conversations",
            subtitle: "Turn spoken words into text instantly. You can follow every conversations with ease during your journey",
            primaryButtonTitle: "Next"
        ),
        OnboardingPage(
            id: 1,
            imageName: "Onboard2 Finish",
            title: "Express yourself with ease",
            subtitle: "Respond faster with smart suggestions tailored to your travel needs",
            primaryButtonTitle: "Next"
        ),
        OnboardingPage(
            id: 2,
            imageName: "Onboard3 Finish",
            title: "Travel with confidence",
            subtitle: "From check-in counter to cabin crew interaction, enjoy smoother and faster conversations throughout your journey",
            primaryButtonTitle: "Next"
        ),
    ]
}
