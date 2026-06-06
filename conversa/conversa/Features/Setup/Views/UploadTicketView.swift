import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

private enum UploadPhase: Equatable {
    case idle
    case uploading
    case complete
}

struct UploadTicketView: View {
    var isNewJourney: Bool = false
    var onUploaded: () -> Void = {}
    var onBack: (() -> Void)?

    @Environment(JourneyStore.self) private var journeyStore
    @Environment(\.dismiss) private var dismiss

    @State private var phase: UploadPhase = .idle
    @State private var uploadProgress: Double = 0
    @State private var advanceTask: Task<Void, Never>?
    @State private var uploadTask: Task<Void, Never>?

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showSourcePicker = false
    @State private var showPhotosPicker = false
    @State private var showFileImporter = false
    @State private var showCamera = false

    private var cardPhase: UploadTicketCardPhase {
        switch phase {
        case .idle:
            return .idle
        case .uploading:
            return .uploading(progress: uploadProgress)
        case .complete:
            return .complete
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SetupHeaderView(
                    title: "Upload Ticket",
                    subtitle: "Upload a photo or document of your flight ticket or your boarding pass",
                    subtitleColor: BrandColors.setupSubtitle
                )

                UploadTicketCard(
                    phase: cardPhase,
                    onTapUpload: { showSourcePicker = true },
                    onOpenCamera: { showCamera = true },
                    onClearUpload: clearUpload
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(BrandColors.setupPageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SetupBackButton(action: handleBack)
            }
        }
        .confirmationDialog("Choose a source", isPresented: $showSourcePicker, titleVisibility: .visible) {
            Button("Photo Library") { showPhotosPicker = true }
            Button("Browse Files") { showFileImporter = true }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, item in
            Task { await loadPhoto(from: item) }
        }
        .sheet(isPresented: $showCamera) {
            CameraImagePicker { image in
                guard let data = image.jpegData(compressionQuality: 0.85) else { return }
                startUpload(with: data)
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.pdf, .png, .jpeg, .image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first,
                      url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                guard let data = try? Data(contentsOf: url) else { return }
                startUpload(with: data)
            case .failure:
                break
            }
        }
        .onDisappear {
            advanceTask?.cancel()
            uploadTask?.cancel()
        }
    }

    private func handleBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            selectedPhotoItem = nil
            startUpload(with: data)
        }
    }

    private func startUpload(with data: Data) {
        uploadTask?.cancel()
        advanceTask?.cancel()

        phase = .uploading
        uploadProgress = 0

        uploadTask = Task {
            journeyStore.uploadedTicketImageData = data

            async let ticket = TicketOCRService().extractTicket(from: data)
            async let progress = animateProgress()

            let extractedTicket = await ticket
            _ = await progress

            guard !Task.isCancelled else { return }

            await MainActor.run {
                uploadProgress = 1
                journeyStore.activeTicket = extractedTicket
                phase = .complete
                scheduleAutoAdvance()
            }
        }
    }

    private func animateProgress() async {
        let steps = 15
        let stepDuration: UInt64 = 100_000_000

        for step in 1...steps {
            guard !Task.isCancelled else { return }
            try? await Task.sleep(nanoseconds: stepDuration)
            let value = 0.9 * Double(step) / Double(steps)
            await MainActor.run {
                uploadProgress = value
            }
        }
    }

    private func scheduleAutoAdvance() {
        advanceTask?.cancel()
        advanceTask = Task {
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                onUploaded()
            }
        }
    }

    private func clearUpload() {
        advanceTask?.cancel()
        uploadTask?.cancel()
        selectedPhotoItem = nil
        uploadProgress = 0
        phase = .idle
    }
}

#Preview("Upload Ticket — Idle") {
    NavigationStack {
        UploadTicketView()
    }
    .environment(JourneyStore())
}

#Preview("Upload Ticket — Uploading") {
    NavigationStack {
        UploadTicketCardPreviewHost(initialPhase: .uploading(progress: 0.75))
    }
    .environment(JourneyStore())
}

#Preview("Upload Ticket — Complete") {
    NavigationStack {
        UploadTicketCardPreviewHost(initialPhase: .complete)
    }
    .environment(JourneyStore())
}

private struct UploadTicketCardPreviewHost: View {
    let initialPhase: UploadTicketCardPhase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SetupHeaderView(
                    title: "Upload Ticket",
                    subtitle: "Upload a photo or document of your flight ticket or your boarding pass",
                    subtitleColor: BrandColors.setupSubtitle
                )

                UploadTicketCard(phase: initialPhase)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(BrandColors.setupPageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SetupBackButton()
            }
        }
    }
}
