import SwiftUI

struct UploadProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(BrandColors.uploadProgressTrack)

                Capsule()
                    .fill(BrandColors.navy)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 8)
        .animation(.easeInOut(duration: 0.25), value: progress)
    }
}

#Preview {
    VStack(spacing: 24) {
        UploadProgressBar(progress: 0.75)
        UploadProgressBar(progress: 0.35)
    }
    .padding()
}
