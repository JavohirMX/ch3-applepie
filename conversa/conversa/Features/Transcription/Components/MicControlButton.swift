import SwiftUI

struct MicControlButton: View {
    let isListening: Bool
    var isProminent: Bool = false
    var showsBreathing: Bool = false
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let baseCoreSize: CGFloat = 88
    private let recordingRingCount = 3
    private let breathingCycleDuration = 2.4

    private var scale: CGFloat { isProminent ? 1.25 : 1.0 }
    private var coreSize: CGFloat { baseCoreSize * scale }
    private var outerSize: CGFloat { coreSize + 56 }
    private var middleSize: CGFloat { coreSize + 20 }
    private var iconSize: CGFloat { 32 * scale }
    private var iconFrame: CGFloat { 36 * scale }

    var body: some View {
        Button(action: action) {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let breathing = breathingValues(at: time)

                ZStack {
                    if isListening {
                        ForEach(0 ..< recordingRingCount, id: \.self) { index in
                            recordingRing(time: time, index: index)
                        }
                    } else {
                        Circle()
                            .fill(BrandColors.micRingMiddle)
                            .frame(width: middleSize * breathing.scale, height: middleSize * breathing.scale)
                            .opacity(breathing.opacity)
                    }

                    Circle()
                        .fill(BrandColors.orange)
                        .frame(width: coreSize, height: coreSize)

                    Image(systemName: isListening ? "stop.fill" : "mic.fill")
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(BrandColors.navy)
                        .frame(width: iconFrame, height: iconFrame)
                }
                .frame(width: outerSize, height: outerSize)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: isProminent)
        .accessibilityLabel(isListening ? "Stop transcription" : "Start transcription")
    }

    private func breathingValues(at time: TimeInterval) -> (scale: CGFloat, opacity: Double) {
        guard (isProminent || showsBreathing), !isListening, !reduceMotion else {
            return (scale: 1, opacity: 1)
        }

        let phase = sin((time * 2 * .pi) / breathingCycleDuration)
        let normalized = (phase + 1) / 2
        let scale = 1 + 0.12 * normalized
        let opacity = 0.85 + 0.15 * normalized
        return (scale: scale, opacity: opacity)
    }

    private func recordingRing(time: TimeInterval, index: Int) -> some View {
        let cycleDuration = 1.6
        let stagger = Double(index) * (cycleDuration / Double(recordingRingCount))
        let phase = (time + stagger).truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let ringScale = 1.0 + phase * 0.42
        let opacity = max(0, 0.55 * (1.0 - phase))
        let size = coreSize * ringScale

        return Circle()
            .stroke(BrandColors.orange.opacity(0.55), lineWidth: 3)
            .frame(width: size, height: size)
            .opacity(opacity)
    }
}

#Preview("Idle") {
    MicControlButton(isListening: false, action: {})
}

#Preview("Prominent") {
    MicControlButton(isListening: false, isProminent: true, action: {})
}

#Preview("Breathing") {
    MicControlButton(isListening: false, showsBreathing: true, action: {})
}

#Preview("Listening") {
    MicControlButton(isListening: true, action: {})
}
