import Foundation

extension ChatMessage {
    /// Create a ChatMessage from a backend MessageResponse DTO.
    init(from response: MessageResponse) {
        let sender: MessageSender = switch response.sender {
        case "user": .user
        case "ai": .other
        default: .system
        }

        self.init(
            id: UUID(uuidString: response.id) ?? UUID(),
            sender: sender,
            text: response.text,
            showsSpeakButton: sender == .user,
            timestamp: response.createdAt,
            isTranscribedLive: sender == .other && response.isTranscribed
        )
    }
}
