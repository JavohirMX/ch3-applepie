import SwiftUI

enum UploadTicketCardPhase: Equatable {
    case idle
    case uploading(progress: Double)
    case complete
}

struct UploadTicketCard: View {
    let phase: UploadTicketCardPhase
    var onTapUpload: () -> Void = {}
    var onOpenCamera: () -> Void = {}
    var onClearUpload: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            switch phase {
            case .idle:
                idleContent
            case .uploading(let progress):
                uploadingContent(progress: progress)
            case .complete:
                completeContent
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(
                BrandColors.uploadZoneBorder,
                style: StrokeStyle(lineWidth: 2, dash: [8, 6])
            )
            .background(
                Color.white,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }

    private var idleContent: some View {
        VStack(spacing: 16) {
            Button(action: onTapUpload) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(BrandColors.uploadIconCircleBackground)
                            .frame(width: 56, height: 56)

                        Image(systemName: "icloud.and.arrow.up.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(BrandColors.navy)
                    }

                    Text("Tap to upload photo")
                        .font(Typography.button)
                        .foregroundStyle(BrandColors.navy)

                    Text("PNG, JPG, or PDF")
                        .font(Typography.suggestionLabel)
                        .foregroundStyle(BrandColors.settingsCaption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            HStack {
                Rectangle()
                    .fill(BrandColors.uploadZoneBorder)
                    .frame(height: 1)
                Text("OR")
                    .font(Typography.suggestionLabel)
                    .foregroundStyle(BrandColors.settingsCaption)
                Rectangle()
                    .fill(BrandColors.uploadZoneBorder)
                    .frame(height: 1)
            }

            Button(action: onOpenCamera) {
                Text("Open Camera")
                    .font(Typography.button)
                    .foregroundStyle(BrandColors.navy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(BrandColors.homeSecondaryButton, in: Capsule())
        }
    }

    private func uploadingContent(progress: Double) -> some View {
        VStack(spacing: 16) {
            Text("\(Int((progress * 100).rounded()))%")
                .font(Typography.uploadProgressPercent)
                .foregroundStyle(BrandColors.navy)

            UploadProgressBar(progress: progress)

            Text("Uploading Document...")
                .font(Typography.button)
                .foregroundStyle(BrandColors.navy)
        }
        .padding(.vertical, 32)
    }

    private var completeContent: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(BrandColors.uploadSuccessGreen)
                    .frame(width: 56, height: 56)

                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Upload Complete")
                .font(Typography.button)
                .foregroundStyle(BrandColors.navy)

            Button(action: onClearUpload) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                    Text("Clear Upload")
                        .font(Typography.suggestionLabel)
                }
                .foregroundStyle(BrandColors.setupSubtitle)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 32)
    }
}

#Preview("Idle") {
    UploadTicketCard(phase: .idle)
        .padding()
        .background(BrandColors.setupPageBackground)
}

#Preview("Uploading") {
    UploadTicketCard(phase: .uploading(progress: 0.75))
        .padding()
        .background(BrandColors.setupPageBackground)
}

#Preview("Complete") {
    UploadTicketCard(phase: .complete)
        .padding()
        .background(BrandColors.setupPageBackground)
}
