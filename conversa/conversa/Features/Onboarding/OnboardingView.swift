import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages = OnboardingPage.pages

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip", action: complete)
                    .font(Typography.skip)
                    .foregroundStyle(BrandColors.navy)
                    .accessibilityLabel("Skip onboarding")
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            TabView(selection: $currentPage) {
                ForEach(pages) { page in
                    OnboardingPageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            pageIndicator
                .padding(.bottom, 16)
                .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")

            primaryButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color.white)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Circle()
                    .fill(page.id == currentPage ? BrandColors.navy : BrandColors.pageDotInactive)
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(pages[currentPage].primaryButtonTitle)
                .font(Typography.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .background(BrandColors.navy, in: Capsule())
        .accessibilityLabel(pages[currentPage].primaryButtonTitle)
    }

    private func primaryAction() {
        if currentPage < pages.count - 1 {
            advanceToNextPage()
        } else {
            complete()
        }
    }

    private func advanceToNextPage() {
        let nextPage = currentPage + 1
        if reduceMotion {
            currentPage = nextPage
        } else {
            withAnimation {
                currentPage = nextPage
            }
        }
    }

    private func complete() {
        onComplete()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
