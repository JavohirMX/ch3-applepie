import SwiftUI

/// Ticket / stamp card with semicircular perforations on the left and right edges only.
struct TicketStubShape: Shape {
    var notchRadius: CGFloat = 5
    var notchSpacing: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = notchRadius
        let spacing = notchSpacing

        let leftEdge = rect.minX + r
        let rightEdge = rect.maxX - r
        let firstScallopY = rect.minY + r + spacing / 2
        let lastScallopY = rect.maxY - r - spacing / 2

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        var y = firstScallopY
        if y - r > rect.minY {
            path.addLine(to: CGPoint(x: rect.maxX, y: y - r))
        }

        while y <= lastScallopY {
            path.addArc(
                center: CGPoint(x: rightEdge, y: y),
                radius: r,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )
            y += spacing
        }

        if y - spacing + r < rect.maxY {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }

        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        y = lastScallopY
        if y + r < rect.maxY {
            path.addLine(to: CGPoint(x: rect.minX, y: y + r))
        }

        while y >= firstScallopY {
            path.addArc(
                center: CGPoint(x: leftEdge, y: y),
                radius: r,
                startAngle: .degrees(90),
                endAngle: .degrees(-90),
                clockwise: false
            )
            y -= spacing
        }

        if firstScallopY - r > rect.minY {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }

        path.closeSubpath()
        return path
    }
}

#Preview {
    TicketStubShape()
        .fill(Color.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(BrandColors.setupPageBackground)
}
