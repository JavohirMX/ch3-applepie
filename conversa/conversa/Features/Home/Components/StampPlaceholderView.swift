import SwiftUI

struct StampPlaceholderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(BrandColors.stampPlaceholder)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .overlay {
                TicketStubShape(notchRadius: 5, notchSpacing: 12)
                    .stroke(BrandColors.uploadZoneBorder.opacity(0.5), lineWidth: 1)
            }
            .clipShape(TicketStubShape(notchRadius: 5, notchSpacing: 12))
    }
}
