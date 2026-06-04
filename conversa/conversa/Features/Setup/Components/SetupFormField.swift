import SwiftUI

struct SetupFormField<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Typography.formLabel)
                .foregroundStyle(BrandColors.navy)

            content()
        }
    }
}

struct SetupFieldBackground<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BrandColors.fieldBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
