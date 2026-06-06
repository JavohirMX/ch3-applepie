import SwiftUI

struct StampPlaceholderView: View {
    var body: some View {
        Image("Plane")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}
