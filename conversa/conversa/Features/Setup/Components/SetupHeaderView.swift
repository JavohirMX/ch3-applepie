import SwiftUI

struct SetupHeaderView: View {
    let title: String
    let subtitle: String
    var subtitleColor: Color = BrandColors.navy

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Typography.setupTitle)
                .foregroundStyle(BrandColors.navy)

            Text(subtitle)
                .font(Typography.setupSubtitle)
                .foregroundStyle(subtitleColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
