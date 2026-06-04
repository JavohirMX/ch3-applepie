import SwiftUI

struct LiveTranscriptArea: View {
    let liveTranscript: String
    static let listeningPlaceholder = "Listening…"

    private var hasTranscript: Bool {
        !liveTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Group {
            if hasTranscript {
                TranscriptDisplayView(text: liveTranscript)
                    .transition(.opacity)
            } else {
                listeningPlaceholderView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasTranscript)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            hasTranscript
                ? liveTranscript
                : "Listening, live transcription in progress"
        )
    }

    private var listeningPlaceholderView: some View {
        ScrollView {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let opacity = 0.45 + 0.35 * (sin(timeline.date.timeIntervalSinceReferenceDate * 2.0) + 1) / 2

                Text(Self.listeningPlaceholder)
                    .font(Typography.transcriptPlaceholder)
                    .foregroundStyle(BrandColors.transcriptPlaceholder)
                    .opacity(opacity)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Placeholder") {
    LiveTranscriptArea(liveTranscript: "")
        .frame(height: 200)
        .padding()
        .background(BrandColors.listeningGradientTop)
}

#Preview("With text") {
    LiveTranscriptArea(liveTranscript: "I need help finding gate 5.")
        .frame(height: 200)
        .padding()
        .background(BrandColors.listeningGradientTop)
}
