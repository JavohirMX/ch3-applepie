import Foundation
import PDFKit
import UIKit
import Vision

enum TicketOCRError: Error {
    case invalidDocument
    case noTextFound
    case visionFailed(Error)
}

struct TicketOCRService {
    func extractTicket(from data: Data) async -> TicketInfo {
        do {
            let text = try await recognizeText(from: data)
            return TicketTextParser.parse(text)
        } catch {
            return .empty
        }
    }

    func recognizeText(from data: Data) async throws -> String {
        let images = try renderImages(from: data)
        guard !images.isEmpty else { throw TicketOCRError.invalidDocument }

        var combinedLines: [String] = []
        for image in images {
            let pageText = try await recognizeText(in: image)
            if !pageText.isEmpty {
                combinedLines.append(pageText)
            }
        }

        let combined = combinedLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !combined.isEmpty else { throw TicketOCRError.noTextFound }
        return combined
    }

    private func renderImages(from data: Data) throws -> [CGImage] {
        if Self.isPDF(data) {
            return try renderPDFPages(from: data)
        }

        guard let image = UIImage(data: data)?.cgImage else {
            throw TicketOCRError.invalidDocument
        }
        return [image]
    }

    private func renderPDFPages(from data: Data) throws -> [CGImage] {
        guard let document = PDFDocument(data: data), document.pageCount > 0 else {
            throw TicketOCRError.invalidDocument
        }

        var images: [CGImage] = []
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { continue }
            if let image = Self.renderPDFPage(page, scale: 2.0) {
                images.append(image)
            }
        }

        guard !images.isEmpty else { throw TicketOCRError.invalidDocument }
        return images
    }

    private func recognizeText(in cgImage: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: TicketOCRError.visionFailed(error))
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                continuation.resume(returning: lines.joined(separator: "\n"))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: TicketOCRError.visionFailed(error))
                }
            }
        }
    }

    static func isPDF(_ data: Data) -> Bool {
        data.prefix(4) == Data("%PDF".utf8)
    }

    static func previewImage(from data: Data) -> UIImage? {
        if isPDF(data) {
            guard let document = PDFDocument(data: data),
                  let page = document.page(at: 0),
                  let cgImage = renderPDFPage(page, scale: 1.0) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
        return UIImage(data: data)
    }

    static func renderPDFPage(_ page: PDFPage, scale: CGFloat) -> CGImage? {
        let bounds = page.bounds(for: .mediaBox)
        let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            context.cgContext.saveGState()
            context.cgContext.translateBy(x: 0, y: size.height)
            context.cgContext.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: context.cgContext)
            context.cgContext.restoreGState()
        }

        return image.cgImage
    }
}
