import SwiftUI

struct ChatMessageRow: View {
    let item: GroupedChatMessage
    let theme: CategoryTheme
    let maxBubbleWidth: CGFloat
    var onSpeak: ((String) -> Void)?

    private var message: ChatMessage { item.message }
    private var alignment: HorizontalAlignment {
        switch message.sender {
        case .user: return .trailing
        case .other: return .leading
        case .system: return .center
        }
    }

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
//            if item.showSenderLabel {
//                Text(senderLabel)
//                    .font(.caption2.weight(.semibold))
//                    .foregroundStyle(AppColors.textSecondary)
//                    .textCase(.uppercase)
//                    .frame(maxWidth: .infinity, alignment: frameAlignment)
//            }

            if message.sender == .system {
                ChatBubbleView(
                    message: message,
                    theme: theme,
                    position: item.position,
                    maxWidth: maxBubbleWidth,
                    onSpeak: onSpeak
                )
            } else {
                HStack {
                    if message.sender == .user { Spacer(minLength: 48) }

                    ChatBubbleView(
                        message: message,
                        theme: theme,
                        position: item.position,
                        maxWidth: maxBubbleWidth,
                        onSpeak: onSpeak
                    )

                    if message.sender == .other { Spacer(minLength: 48) }
                }
            }

            if item.showTimestamp, let timestamp = message.timestamp {
                metadataView(timestamp: timestamp)
            }
        }
        .padding(.top, topPadding)
        .frame(maxWidth: .infinity)
    }

    private var senderLabel: String {
        switch message.sender {
        case .user: return "You"
        case .other: return "Them"
        case .system: return ""
        }
    }

    private var frameAlignment: Alignment {
        message.sender == .user ? .trailing : .leading
    }

    private var topPadding: CGFloat {
        if message.sender == .system { return 6 }
        return item.position.isFirst ? 10 : 3
    }

    @ViewBuilder
    private func metadataView(timestamp: Date) -> some View {
        HStack(spacing: 6) {
            if message.isTranscribedLive, message.sender == .other {
                Label("Transcribed live", systemImage: "waveform")
                    .font(.caption2)
                    .foregroundStyle(theme.primary)
            }
            Text(timestamp, format: .dateTime.hour().minute())
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: frameAlignment)
    }
}
