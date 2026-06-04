import SwiftUI

struct SetupHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Typography.setupTitle)
                .foregroundStyle(BrandColors.navy)

            Text(subtitle)
                .font(Typography.setupSubtitle)
                .foregroundStyle(BrandColors.navy)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
