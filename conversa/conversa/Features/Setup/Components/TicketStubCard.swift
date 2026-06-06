import SwiftUI

struct TicketStubCard<Content: View>: View {
    let title: String
    var titleAlignment: HorizontalAlignment = .leading
    var showsDashedDivider: Bool = false
    var shape: TicketStubShape = TicketStubShape()
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: showsDashedDivider ? 12 : 16) {
            Text(title)
                .font(Typography.cardTitle)
                .foregroundStyle(BrandColors.navy)
                .frame(maxWidth: .infinity, alignment: Alignment(horizontal: titleAlignment, vertical: .center))

            if showsDashedDivider {
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(BrandColors.cardDivider)
                    .frame(height: 1)
            }

            content()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(shape)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}
