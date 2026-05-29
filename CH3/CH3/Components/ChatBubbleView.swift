import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    let theme: CategoryTheme
    let position: MessageGroupPosition
    let maxWidth: CGFloat
    var onSpeak: ((String) -> Void)?

    private var isUser: Bool { message.sender == .user }
    private var isSystem: Bool { message.sender == .system }

    var body: some View {
        Group {
            if isSystem {
                systemBubble
            } else {
                messageBubble
            }
        }
        .frame(maxWidth: maxWidth, alignment: isUser ? .trailing : .leading)
    }

    private var messageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.text)
                .font(.body)
                .foregroundStyle(isUser ? .white : .primary)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)

            if message.showsSpeakButton, let onSpeak {
                HStack {
                    Spacer()
                    Button {
                        onSpeak(message.text)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                            .frame(width: 44, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Play message aloud")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isUser ? theme.primary : AppColors.incomingBubble)
        .clipShape(bubbleShape)
    }

    private var systemBubble: some View {
        Text(message.text)
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }

    private var bubbleShape: UnevenRoundedRectangle {
        let radius: CGFloat = 18
        let join: CGFloat = 12
        let tail: CGFloat = 6

        if isUser {
            return UnevenRoundedRectangle(
                topLeadingRadius: radius,
                bottomLeadingRadius: radius,
                bottomTrailingRadius: position.showsTail ? tail : (position.isOnly ? radius : join),
                topTrailingRadius: position.isFirst ? radius : join,
                style: .continuous
            )
        } else {
            return UnevenRoundedRectangle(
                topLeadingRadius: position.isFirst ? radius : join,
                bottomLeadingRadius: position.showsTail ? tail : (position.isOnly ? radius : join),
                bottomTrailingRadius: radius,
                topTrailingRadius: radius,
                style: .continuous
            )
        }
    }
}
