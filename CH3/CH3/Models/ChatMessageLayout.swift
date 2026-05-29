import Foundation

enum MessageSender: Hashable {
    case user
    case other
    case system
}

struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let sender: MessageSender
    let text: String
    let showsSpeakButton: Bool
    let timestamp: Date?
    let isTranscribedLive: Bool

    init(
        id: UUID = UUID(),
        sender: MessageSender,
        text: String,
        showsSpeakButton: Bool = false,
        timestamp: Date? = Date(),
        isTranscribedLive: Bool = false
    ) {
        self.id = id
        self.sender = sender
        self.text = text
        self.showsSpeakButton = showsSpeakButton
        self.timestamp = timestamp
        self.isTranscribedLive = isTranscribedLive
    }

    static func user(
        _ text: String,
        showsSpeakButton: Bool = true,
        timestamp: Date? = Date()
    ) -> ChatMessage {
        ChatMessage(sender: .user, text: text, showsSpeakButton: showsSpeakButton, timestamp: timestamp)
    }

    static func other(
        _ text: String,
        isTranscribedLive: Bool = true,
        timestamp: Date? = Date()
    ) -> ChatMessage {
        ChatMessage(sender: .other, text: text, showsSpeakButton: false, timestamp: timestamp, isTranscribedLive: isTranscribedLive)
    }

    static func system(_ text: String) -> ChatMessage {
        ChatMessage(sender: .system, text: text, showsSpeakButton: false, timestamp: nil)
    }
}

struct MessageGroupPosition: Hashable {
    let isFirst: Bool
    let isLast: Bool

    var isOnly: Bool { isFirst && isLast }
    var showsTail: Bool { isLast }
}

struct GroupedChatMessage: Identifiable, Hashable {
    let id: UUID
    let message: ChatMessage
    let position: MessageGroupPosition
    let showSenderLabel: Bool
    let showTimestamp: Bool

    init(message: ChatMessage, position: MessageGroupPosition, showSenderLabel: Bool, showTimestamp: Bool) {
        self.id = message.id
        self.message = message
        self.position = position
        self.showSenderLabel = showSenderLabel
        self.showTimestamp = showTimestamp
    }
}

enum ChatMessageLayout {
    static func grouped(_ messages: [ChatMessage]) -> [GroupedChatMessage] {
        guard !messages.isEmpty else { return [] }

        return messages.indices.map { index in
            let message = messages[index]
            let sender = message.sender

            let isFirst = index == 0 || messages[index - 1].sender != sender
            let isLast = index == messages.count - 1 || messages[index + 1].sender != sender
            let position = MessageGroupPosition(isFirst: isFirst, isLast: isLast)

            return GroupedChatMessage(
                message: message,
                position: position,
                showSenderLabel: isFirst && sender != .system,
                showTimestamp: isLast && sender != .system && message.timestamp != nil
            )
        }
    }
}
