import Foundation

/// Maps country codes to speech recognition and synthesis locales.
enum LocaleMapper {
    /// Returns the best speech locale for a given country code.
    /// Used by both SFSpeechRecognizer (STT) and AVSpeechSynthesizer (TTS).
    static func speechLocale(for countryCode: String) -> Locale {
        switch countryCode.uppercased() {
        // East Asia
        case "JP": return Locale(identifier: "ja-JP")
        case "CN": return Locale(identifier: "zh-CN")
        case "KR": return Locale(identifier: "ko-KR")
        case "TW": return Locale(identifier: "zh-TW")
        case "HK": return Locale(identifier: "zh-HK")

        // Southeast Asia
        case "ID": return Locale(identifier: "id-ID")
        case "TH": return Locale(identifier: "th-TH")
        case "VN": return Locale(identifier: "vi-VN")
        case "MY": return Locale(identifier: "ms-MY")
        case "PH": return Locale(identifier: "en-PH")

        // South Asia
        case "IN": return Locale(identifier: "en-IN")

        // Europe
        case "FR": return Locale(identifier: "fr-FR")
        case "DE": return Locale(identifier: "de-DE")
        case "ES": return Locale(identifier: "es-ES")
        case "IT": return Locale(identifier: "it-IT")
        case "PT": return Locale(identifier: "pt-PT")
        case "NL": return Locale(identifier: "nl-NL")
        case "RU": return Locale(identifier: "ru-RU")
        case "TR": return Locale(identifier: "tr-TR")
        case "GR": return Locale(identifier: "el-GR")
        case "PL": return Locale(identifier: "pl-PL")
        case "SE": return Locale(identifier: "sv-SE")
        case "NO": return Locale(identifier: "nb-NO")
        case "DK": return Locale(identifier: "da-DK")
        case "FI": return Locale(identifier: "fi-FI")

        // Middle East
        case "SA", "AE", "QA", "KW", "BH", "OM": return Locale(identifier: "ar-SA")
        case "IL": return Locale(identifier: "he-IL")

        // Americas
        case "BR": return Locale(identifier: "pt-BR")
        case "MX": return Locale(identifier: "es-MX")
        case "AR": return Locale(identifier: "es-AR")

        // Oceania
        case "AU": return Locale(identifier: "en-AU")
        case "NZ": return Locale(identifier: "en-NZ")

        // Africa
        case "ZA": return Locale(identifier: "en-ZA")
        case "EG": return Locale(identifier: "ar-EG")

        // Default: US English
        default: return Locale(identifier: "en-US")
        }
    }

    /// Returns a human-readable language name for the locale (for UI display).
    static func languageName(for countryCode: String) -> String {
        let locale = speechLocale(for: countryCode)
        return locale.localizedString(forIdentifier: locale.identifier) ?? locale.identifier
    }
}
