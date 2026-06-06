import SwiftUI

struct SetupFormField<Content: View>: View {
    let label: String
    var labelColor: Color = BrandColors.navy
    var labelFont: Font = Typography.formLabel
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(labelFont)
                .foregroundStyle(labelColor)

            content()
        }
    }
}

struct SetupFieldBackground<Content: View>: View {
    var usesCapsule: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if usesCapsule {
                    Capsule().fill(BrandColors.fieldBackground)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BrandColors.fieldBackground)
                }
            }
    }
}
