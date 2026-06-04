import PhotosUI
import SwiftUI

struct UploadTicketView: View {
    var isNewJourney: Bool = false
    var onUploaded: () -> Void = {}

    @Environment(JourneyStore.self) private var journeyStore

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false

    private var canUpload: Bool {
        selectedImage != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SetupHeaderView(
                        title: "Upload Ticket",
                        subtitle: "Upload a photo or document of your flight ticket or your boarding pass"
                    )

                    uploadZone
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            SetupPrimaryButton(title: "Upload", isEnabled: canUpload, action: upload)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, item in
            Task { await loadPhoto(from: item) }
        }
        .sheet(isPresented: $showCamera) {
            CameraImagePicker { image in
                selectedImage = image
            }
        }
    }

    private var uploadZone: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                VStack(spacing: 10) {
                    Image(systemName: "icloud.and.arrow.up.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(BrandColors.navy.opacity(0.7))

                    Text(selectedImage != nil ? "Photo selected — tap to change" : "Tap to upload photo")
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

            Button {
                showCamera = true
            } label: {
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

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await MainActor.run {
            selectedImage = image
        }
    }

    private func upload() {
        guard let selectedImage, let data = selectedImage.jpegData(compressionQuality: 0.85) else { return }
        journeyStore.uploadedTicketImageData = data
        onUploaded()
    }
}
