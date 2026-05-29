import SwiftUI

/// iOS 26 Liquid Glass text field for onboarding / context forms.
struct FormGlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var multiline: Bool = false
    var submitLabel: SubmitLabel = .continue
    var onSubmit: (() -> Void)?

    private let rowHeight: CGFloat = 36

    var body: some View {
        GlassEffectContainer {
            Group {
                if multiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(2...4)
                } else {
                    TextField(placeholder, text: $text)
                        .lineLimit(1)
                }
            }
            .font(.system(size: 17, weight: .regular, design: .rounded))
            .foregroundStyle(.primary)
            .textFieldStyle(.plain)
            .submitLabel(submitLabel)
            .onSubmit { onSubmit?() }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: rowHeight, maxHeight: multiline ? 88 : rowHeight, alignment: .center)
            .glassEffect(.regular.tint(.white.opacity(0.55)).interactive(), in: .capsule)
        }
    }
}

/// Segmented yes/no control inside Liquid Glass (native picker).
struct FormGlassYesNoPicker: View {
    @Binding var selection: String

    var body: some View {
        GlassEffectContainer {
            Picker("Answer", selection: $selection) {
                Text("Yes").tag("Yes")
                Text("No").tag("No")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(height: 36)
            .glassEffect(.regular.tint(.white.opacity(0.55)).interactive(), in: .capsule)
        }
        .onAppear {
            if selection.isEmpty { selection = "Yes" }
        }
    }
}

/// Compact native date pickers inside Liquid Glass.
struct FormGlassDateRangeField: View {
    @Binding var checkIn: Date
    @Binding var checkOut: Date

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 8) {
                DatePicker("Check-in", selection: $checkIn, displayedComponents: .date)
                DatePicker("Check-out", selection: $checkOut, displayedComponents: .date)
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassEffect(.regular.tint(.white.opacity(0.55)).interactive(), in: .rect(cornerRadius: 16))
        }
    }
}
