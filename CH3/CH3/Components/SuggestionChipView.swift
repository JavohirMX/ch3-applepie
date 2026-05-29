import SwiftUI

struct SuggestionChipView: View {
    let text: String
    let theme: CategoryTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .multilineTextAlignment(.leading)
                .suggestionPill(theme: theme)
        }
        .buttonStyle(.plain)
    }
}
