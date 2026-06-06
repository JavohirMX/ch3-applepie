import SwiftUI

struct PersonalPreferencesView: View {
    let mode: PreferencesEditorMode
    var onContinue: () -> Void = {}
    var onSkip: (() -> Void)?
    var onBack: (() -> Void)?

    @Environment(JourneyStore.self) private var journeyStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    @State private var meal = ""
    @State private var seat = ""
    @State private var countryCode = "+62"
    @State private var phone = ""
    @State private var disability = ""

    private var showsSkip: Bool {
        mode == .firstRun
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SetupHeaderView(
                    title: "Set Preferences",
                    subtitle: "This preferences will make your suggestion smoother thoughout the journey!",
                    subtitleColor: BrandColors.setupSubtitle
                )

                TicketStubCard(
                    title: "Personal Preferences",
                    titleAlignment: .center,
                    showsDashedDivider: true,
                    shape: TicketStubShape(notchRadius: 5, notchSpacing: 12)
                ) {
                    VStack(spacing: 16) {
                        preferencePicker(
                            label: "Meal/Dietary Restriction",
                            selection: $meal,
                            options: MealPreferenceOption.allCases.map(\.rawValue),
                            placeholder: "eg. Vegan"
                        )
                        preferencePicker(
                            label: "Seat Preferences",
                            selection: $seat,
                            options: SeatPreferenceOption.allCases.map(\.rawValue),
                            placeholder: "eg. Window Seat"
                        )
                        emergencyContactField
                        preferencePicker(
                            label: "Type of Disabilities",
                            selection: $disability,
                            options: DisabilityOption.allCases.map(\.rawValue),
                            placeholder: "eg. Deaf, Hard of Hearing, etc"
                        )

                        SetupPrimaryButton(
                            title: "Confirm",
                            foregroundColor: BrandColors.navy,
                            action: confirm
                        )
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(BrandColors.setupPageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SetupBackButton(action: handleBack)
            }
            if showsSkip, let onSkip {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip", action: onSkip)
                        .font(Typography.skip)
                        .foregroundStyle(BrandColors.navy)
                }
            }
        }
        .onAppear(perform: loadFromStore)
    }

    private var emergencyContactField: some View {
        SetupFormField(
            label: "Emergency Contact",
            labelColor: BrandColors.formLabelMuted,
            labelFont: Typography.formLabelMuted
        ) {
            HStack(spacing: 8) {
                Menu {
                    ForEach(CountryCodeOption.allCases) { option in
                        Button(option.rawValue) { countryCode = option.rawValue }
                    }
                } label: {
                    SetupFieldBackground(usesCapsule: true) {
                        HStack {
                            Text(countryCode)
                                .foregroundStyle(BrandColors.navy)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(BrandColors.navy)
                        }
                    }
                    .frame(width: 88)
                }

                TextField("Phone number", text: $phone)
                    .keyboardType(.phonePad)
                    .foregroundStyle(BrandColors.navy)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(BrandColors.fieldBackground, in: Capsule())
            }
        }
    }

    private func preferencePicker(
        label: String,
        selection: Binding<String>,
        options: [String],
        placeholder: String
    ) -> some View {
        SetupFormField(
            label: label,
            labelColor: BrandColors.formLabelMuted,
            labelFont: Typography.formLabelMuted
        ) {
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection.wrappedValue = option }
                }
            } label: {
                SetupFieldBackground(usesCapsule: true) {
                    HStack {
                        Text(selection.wrappedValue.isEmpty ? placeholder : selection.wrappedValue)
                            .foregroundStyle(
                                selection.wrappedValue.isEmpty
                                    ? BrandColors.editorPlaceholder
                                    : BrandColors.navy
                            )
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(BrandColors.navy)
                    }
                }
            }
        }
    }

    private func handleBack() {
        if let onBack {
            onBack()
        } else {
            hasCompletedOnboarding = false
        }
    }

    private func loadFromStore() {
        let prefs = journeyStore.userPreferences
        meal = prefs.mealPreference
        seat = prefs.seatPreference
        countryCode = prefs.emergencyCountryCode
        phone = prefs.emergencyPhone
        disability = prefs.disabilityType
    }

    private func confirm() {
        journeyStore.userPreferences = UserPreferences(
            mealPreference: meal,
            seatPreference: seat,
            emergencyCountryCode: countryCode,
            emergencyPhone: phone,
            disabilityType: disability
        )
        onContinue()
    }
}

#Preview("Set Preferences — Design") {
    NavigationStack {
        PersonalPreferencesView(
            mode: .firstRun,
            onContinue: {},
            onSkip: {}
        )
    }
    .environment(JourneyStore())
}
