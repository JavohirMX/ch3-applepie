import SwiftUI

struct SetupPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var foregroundColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.button)
                .foregroundStyle(isEnabled ? foregroundColor : BrandColors.navy)
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
