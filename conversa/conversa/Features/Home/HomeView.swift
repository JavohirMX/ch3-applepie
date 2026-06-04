import SwiftUI

struct HomeView: View {
    var onContinueJourney: () -> Void
    var onNewJourney: () -> Void
    var onOpenSettings: () -> Void

    @Environment(JourneyStore.self) private var journeyStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Home")
                    .font(Typography.homeTitle)
                    .foregroundStyle(BrandColors.navy)

                Spacer()

                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(BrandColors.navy)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Spacer(minLength: 24)

            StampPlaceholderView()
                .padding(.horizontal, 40)

            journeyLabels
                .padding(.top, 20)
                .padding(.horizontal, 48)

            Spacer(minLength: 32)

            VStack(spacing: 12) {
                Button(action: onContinueJourney) {
                    Text("Continue journey")
                        .font(Typography.button)
                        .foregroundStyle(BrandColors.navy)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .background(BrandColors.orange, in: Capsule())
                .disabled(!journeyStore.hasActiveJourney)
                .opacity(journeyStore.hasActiveJourney ? 1 : 0.5)

                Button(action: onNewJourney) {
                    Text("New journey")
                        .font(Typography.button)
                        .foregroundStyle(BrandColors.navy)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .background(BrandColors.homeSecondaryButton, in: Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarHidden(true)
    }

    private var journeyLabels: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("from")
                    .font(Typography.journeyLabel)
                    .foregroundStyle(BrandColors.navy)
                Text(journeyStore.activeTicket?.fromCityLabel ?? "—")
                    .font(Typography.journeyCity)
                    .foregroundStyle(BrandColors.navy)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("to")
                    .font(Typography.journeyLabel)
                    .foregroundStyle(BrandColors.navy)
                Text(journeyStore.activeTicket?.toCityLabel ?? "—")
                    .font(Typography.journeyCity)
                    .foregroundStyle(BrandColors.navy)
            }
        }
    }
}
