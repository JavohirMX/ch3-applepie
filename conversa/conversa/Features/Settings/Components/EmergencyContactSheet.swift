import SwiftUI

struct EmergencyContactSheet: View {
    @Environment(JourneyStore.self) private var journeyStore
    @Environment(\.dismiss) private var dismiss

    @State private var countryCode = "+62"
    @State private var phone = ""

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(alignment: .leading, spacing: 16) {
                phoneInputRow

                Text("Add your emergency contact phone number")
                    .font(Typography.suggestionLabel)
                    .foregroundStyle(BrandColors.settingsCaption)

                saveButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer(minLength: 0)
        }
        .background(BrandColors.setupPageBackground)
        .onAppear(perform: loadFromStore)
    }

    private var header: some View {
        ZStack {
            Text("Emergency Contact")
                .font(Typography.body.weight(.semibold))
                .foregroundStyle(BrandColors.navy)

            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(BrandColors.navy)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var phoneInputRow: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(CountryCodeOption.allCases) { option in
                    Button(option.rawValue) { countryCode = option.rawValue }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(countryCode)
                        .foregroundStyle(BrandColors.navy)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(BrandColors.navy)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }

            TextField("812-345-678", text: $phone)
                .keyboardType(.phonePad)
                .foregroundStyle(BrandColors.navy)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var saveButton: some View {
        Button(action: save) {
            Text("Save")
                .font(Typography.button)
                .foregroundStyle(BrandColors.navy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .background(Color.white, in: Capsule())
        .padding(.top, 8)
    }

    private func loadFromStore() {
        let prefs = journeyStore.userPreferences
        countryCode = prefs.emergencyCountryCode
        phone = prefs.emergencyPhone
    }

    private func save() {
        var prefs = journeyStore.userPreferences
        prefs.emergencyCountryCode = countryCode
        prefs.emergencyPhone = phone
        journeyStore.userPreferences = prefs
        dismiss()
    }
}

#Preview {
    EmergencyContactSheet()
        .environment(JourneyStore())
}
