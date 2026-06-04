import SwiftUI

struct SetupPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.button)
                .foregroundStyle(isEnabled ? .white : BrandColors.navy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .background(
            isEnabled ? BrandColors.orange : BrandColors.setupDisabledButton,
            in: Capsule()
        )
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }
}
