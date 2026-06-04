import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @State private var journeyStore = JourneyStore()

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            } else if !hasCompletedSetup {
                SetupFlowView {
                    hasCompletedSetup = true
                }
            } else {
                MainFlowView()
            }
        }
        .environment(journeyStore)
    }
}

#Preview("Onboarding gate") {
    RootView()
}

#Preview("Main after setup") {
    let defaults = UserDefaults()
    defaults.set(true, forKey: "hasCompletedOnboarding")
    defaults.set(true, forKey: "hasCompletedSetup")
    return RootView()
        .defaultAppStorage(defaults)
}
