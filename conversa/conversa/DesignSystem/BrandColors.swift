import SwiftUI

enum BrandColors {
    // MARK: - Core brand

    static let navy = Color("BrandNavy")
    static let orange = Color("BrandOrange")
    static let body = Color.primary
    static let white = Color.white

    // MARK: - Text

    static let secondaryText = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255)
    static let setupSubtitle = Color(red: 142 / 255, green: 154 / 255, blue: 175 / 255)
    static let formLabelMuted = setupSubtitle
    static let settingsCaption = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 0.85)
    static let settingsSectionHeader = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 0.75)
    static let suggestionLabel = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 0.85)
    static let editorPlaceholder = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 0.65)
    static let pageDotInactive = Color(red: 199 / 255, green: 199 / 255, blue: 204 / 255)

    // MARK: - Setup flow

    static let setupPageBackground = Color(red: 240 / 255, green: 242 / 255, blue: 245 / 255)
    static let fieldBackground = Color(red: 237 / 255, green: 240 / 255, blue: 245 / 255)
    static let cardDivider = Color(red: 142 / 255, green: 154 / 255, blue: 175 / 255, opacity: 0.35)
    static let setupDisabledButton = Color(red: 1, green: 217 / 255, blue: 166 / 255)

    // MARK: - Upload ticket

    static let uploadZoneBorder = Color(red: 184 / 255, green: 209 / 255, blue: 235 / 255)
    static let uploadZoneBackground = Color(red: 240 / 255, green: 247 / 255, blue: 255 / 255)
    static let uploadIconCircleBackground = uploadZoneBackground
    static let uploadProgressTrack = Color(red: 230 / 255, green: 237 / 255, blue: 247 / 255)
    static let uploadSuccessGreen = Color(red: 76 / 255, green: 217 / 255, blue: 100 / 255)

    // MARK: - Home & actions

    static let homeSecondaryButton = Color(red: 234 / 255, green: 239 / 255, blue: 246 / 255)
    static let actionButtonBackground = uploadProgressTrack
    static let stampPlaceholder = Color(red: 224 / 255, green: 230 / 255, blue: 237 / 255)

    // MARK: - Editor & suggestions

    static let editorBackground = fieldBackground
    static let compactSuggestionBackground = uploadZoneBackground

    // MARK: - Transcription

    static let listeningGradientTop = white
    static let listeningGradientBottom = Color(red: 224 / 255, green: 237 / 255, blue: 250 / 255)
    static let transcriptPlaceholder = Color(red: 209 / 255, green: 209 / 255, blue: 224 / 255)
    static let micRingMiddle = Color(red: 250 / 255, green: 140 / 255, blue: 46 / 255, opacity: 0.35)
    static let micRingOuter = Color(red: 224 / 255, green: 237 / 255, blue: 250 / 255, opacity: 0.8)
}
