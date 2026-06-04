import SwiftUI

struct TicketStubShape: Shape {
    var notchRadius: CGFloat = 6
    var notchSpacing: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let insetY = notchRadius
        let inner = CGRect(
            x: rect.minX,
            y: rect.minY + insetY,
            width: rect.width,
            height: rect.height - insetY * 2
        )

        path.move(to: CGPoint(x: inner.minX, y: inner.minY))
        addNotchedEdge(path: &path, y: inner.minY, xStart: inner.minX, xEnd: inner.maxX, outward: false)
        addNotchedEdge(path: &path, y: inner.maxY, xStart: inner.maxX, xEnd: inner.minX, outward: true)
        path.closeSubpath()
        return path
    }

    private func addNotchedEdge(
        path: inout Path,
        y: CGFloat,
        xStart: CGFloat,
        xEnd: CGFloat,
        outward: Bool
    ) {
        let goingRight = xEnd > xStart
        var x = xStart
        let step = notchSpacing

        while (goingRight && x < xEnd) || (!goingRight && x > xEnd) {
            let nextX = goingRight ? min(x + step, xEnd) : max(x - step, xEnd)
            let midX = (x + nextX) / 2
            let bump = outward ? notchRadius : -notchRadius
            path.addQuadCurve(
                to: CGPoint(x: nextX, y: y),
                control: CGPoint(x: midX, y: y + bump)
            )
            x = nextX
            if x == xEnd { break }
        }
    }
}
