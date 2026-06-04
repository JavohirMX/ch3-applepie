import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 320)
                .padding(.horizontal, 24)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(Typography.headline)
                    .foregroundStyle(BrandColors.orange)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(Typography.body)
                    .foregroundStyle(BrandColors.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .accessibilityElement(children: .combine)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Less stress") {
    OnboardingPageView(page: OnboardingPage.pages[0])
        .background(Color.white)
}

#Preview("Personalized") {
    OnboardingPageView(page: OnboardingPage.pages[1])
        .background(Color.white)
}
