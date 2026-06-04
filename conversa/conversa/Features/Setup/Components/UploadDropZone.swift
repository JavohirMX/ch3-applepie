import SwiftUI

struct UploadDropZone: View {
    let hasImage: Bool
    let onPickPhoto: () -> Void
    let onOpenCamera: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Button(action: onPickPhoto) {
                VStack(spacing: 10) {
                    Image(systemName: "icloud.and.arrow.up.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(BrandColors.navy.opacity(0.7))

                    Text(hasImage ? "Photo selected — tap to change" : "Tap to upload photo")
                        .font(Typography.body)
                        .foregroundStyle(BrandColors.navy)

                    Text("PNG, JPG, or PDF (max. 800x400px)")
                        .font(Typography.suggestionLabel)
                        .foregroundStyle(BrandColors.settingsCaption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
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
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(BrandColors.navy, in: Capsule())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    BrandColors.uploadZoneBorder,
                    style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                )
                .background(
                    BrandColors.uploadZoneBackground,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
        )
    }
}
