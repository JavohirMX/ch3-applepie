import SwiftUI

struct SettingsView: View {
    var onEditBoardingPass: () -> Void

    @Environment(JourneyStore.self) private var journeyStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @State private var showResetConfirmation = false
    @State private var showEmergencyContactSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(Typography.homeTitle)
                    .foregroundStyle(BrandColors.navy)
                    .onLongPressGesture {
                        showResetConfirmation = true
                    }

                VStack(alignment: .leading, spacing: 8) {
                    settingsCard {
                        HStack {
                            Text("My Ticket")
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

                    settingsCard {
                        VStack(spacing: 0) {
                            dropdownPreferenceRow(
                                title: "Meal Preferences",
                                options: MealPreferenceOption.allCases.map(\.rawValue),
                                currentValue: journeyStore.userPreferences.mealPreference
                            ) { value in
                                updatePreferences { $0.mealPreference = value }
                            }
                            divider
                            dropdownPreferenceRow(
                                title: "Seating Position",
                                options: SeatPreferenceOption.allCases.map(\.rawValue),
                                currentValue: journeyStore.userPreferences.seatPreference
                            ) { value in
                                updatePreferences { $0.seatPreference = value }
                            }
                            divider
                            emergencyContactRow
                            divider
                            dropdownPreferenceRow(
                                title: "Type of Disability",
                                options: DisabilityOption.allCases.map(\.rawValue),
                                currentValue: journeyStore.userPreferences.disabilityType,
                                showsEditAffordance: false
                            ) { value in
                                updatePreferences { $0.disabilityType = value }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(BrandColors.setupPageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEmergencyContactSheet) {
            EmergencyContactSheet()
                .presentationDetents([.medium, .large])
        }
        .alert("Reset app?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetApp()
            }
        } message: {
            Text("This clears your ticket, preferences, and transcript and restarts from the beginning.")
        }
    }

    private func resetApp() {
        journeyStore.resetAll()
        hasCompletedSetup = false
        hasCompletedOnboarding = false
    }

    private func updatePreferences(_ mutate: (inout UserPreferences) -> Void) {
        var prefs = journeyStore.userPreferences
        mutate(&prefs)
        journeyStore.userPreferences = prefs
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
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private func dropdownPreferenceRow(
        title: String,
        options: [String],
        currentValue: String,
        showsEditAffordance: Bool = true,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    if currentValue == option {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack(alignment: .center) {
                Text(title)
                    .font(Typography.body)
                    .foregroundStyle(BrandColors.navy)
                Spacer()
                if showsEditAffordance {
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
            .contentShape(Rectangle())
        }
    }

    private var emergencyContactRow: some View {
        Button {
            showEmergencyContactSheet = true
        } label: {
            HStack(alignment: .center) {
                Text("Emergency Contact")
                    .font(Typography.body)
                    .foregroundStyle(BrandColors.navy)
                Spacer()
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
