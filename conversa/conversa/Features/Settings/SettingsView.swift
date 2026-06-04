import SwiftUI

struct SettingsView: View {
    var onEditBoardingPass: () -> Void
    var onEditPreferences: () -> Void

    @Environment(JourneyStore.self) private var journeyStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(Typography.homeTitle)
                    .foregroundStyle(BrandColors.navy)

                VStack(alignment: .leading, spacing: 8) {
                    settingsCard {
                        HStack {
                            Text("My boarding pass")
                                .font(Typography.body)
                                .foregroundStyle(BrandColors.navy)
                            Spacer()
                            Button(action: onEditBoardingPass) {
                                HStack(spacing: 4) {
                                    Text("Edit")
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                }
                                .font(Typography.suggestionBody)
                                .foregroundStyle(BrandColors.settingsCaption)
                            }
                        }
                    }

                    Text("Edit information about your current journey's ticket")
                        .font(Typography.suggestionLabel)
                        .foregroundStyle(BrandColors.settingsCaption)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferences")
                        .font(Typography.settingsSectionLabel)
                        .foregroundStyle(BrandColors.settingsSectionHeader)
                        .textCase(.uppercase)

                    settingsCard {
                        VStack(spacing: 0) {
                            preferenceRow(
                                title: "Meal Preferences",
                                showsEdit: true,
                                action: onEditPreferences
                            )
                            divider
                            preferenceRow(
                                title: "Seating Position",
                                showsEdit: true,
                                action: onEditPreferences
                            )
                            divider
                            preferenceRow(
                                title: "Emergency Contact",
                                subtitle: journeyStore.userPreferences.emergencyContactDisplay,
                                showsEdit: false,
                                action: onEditPreferences
                            )
                            divider
                            preferenceRow(
                                title: "Type of Disabilty",
                                subtitle: journeyStore.userPreferences.disabilityType.isEmpty
                                    ? "Not set"
                                    : journeyStore.userPreferences.disabilityType,
                                showsEdit: false,
                                action: onEditPreferences
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .frame(height: 1)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private func preferenceRow(
        title: String,
        subtitle: String? = nil,
        showsEdit: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(BrandColors.navy)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(Typography.suggestionLabel)
                            .foregroundStyle(BrandColors.settingsCaption)
                    }
                }
                Spacer()
                if showsEdit {
                    HStack(spacing: 6) {
                        Text("Edit")
                            .font(Typography.suggestionBody)
                            .foregroundStyle(BrandColors.settingsCaption)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(BrandColors.settingsCaption)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
