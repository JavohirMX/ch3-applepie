import SwiftUI

struct SetupBackButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(BrandColors.navy)
                .frame(width: 36, height: 36)
                .background(Color.white, in: Circle())
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

#Preview {
    SetupBackButton()
        .padding()
        .background(BrandColors.setupPageBackground)
}
