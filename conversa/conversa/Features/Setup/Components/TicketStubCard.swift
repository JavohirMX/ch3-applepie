import SwiftUI

struct TicketStubCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(Typography.cardTitle)
                .foregroundStyle(BrandColors.navy)
                .frame(maxWidth: .infinity, alignment: .leading)

            content()
        }
        .padding(20)
        .background(Color.white, in: TicketStubShape())
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}
