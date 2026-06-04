import SwiftUI

struct MicControlButton: View {
    let isListening: Bool
    let action: () -> Void

    private let coreSize: CGFloat = 88
    private var outerSize: CGFloat { coreSize + 56 }
    private var middleSize: CGFloat { coreSize + 28 }
    private let recordingRingCount = 3

    var body: some View {
        Button(action: action) {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    if isListening {
                        ForEach(0 ..< recordingRingCount, id: \.self) { index in
                            recordingRing(time: time, index: index)
                        }
                    } else {
                        Circle()
                            .fill(BrandColors.micRingOuter)
                            .frame(width: outerSize, height: outerSize)

                        Circle()
                            .fill(BrandColors.micRingMiddle)
                            .frame(width: middleSize, height: middleSize)
                    }

                    Circle()
                        .fill(BrandColors.orange)
                        .frame(width: coreSize, height: coreSize)

                    Image(systemName: isListening ? "stop.fill" : "mic.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(BrandColors.navy)
                        .frame(width: 36, height: 36)
                }
                .frame(width: outerSize, height: outerSize)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isListening ? "Stop transcription" : "Start transcription")
    }

    private func recordingRing(time: TimeInterval, index: Int) -> some View {
        let cycleDuration = 1.6
        let stagger = Double(index) * (cycleDuration / Double(recordingRingCount))
        let phase = (time + stagger).truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let scale = 1.0 + phase * 0.42
        let opacity = max(0, 0.55 * (1.0 - phase))
        let size = coreSize * scale

        return Circle()
            .stroke(BrandColors.orange.opacity(0.55), lineWidth: 3)
            .frame(width: size, height: size)
            .opacity(opacity)
    }
}

#Preview("Idle") {
    MicControlButton(isListening: false, action: {})
}

#Preview("Listening") {
    MicControlButton(isListening: true, action: {})
}
