//
//  ConversationLanguage.swift
//  LinguaEar
//

import Foundation

/// All supported languages for LinguaEar.
/// - `azureCode` is what we send to Azure Translator.
/// - `ttsCode` is what we pass to AVSpeech for spoken output.
/// - `localeIdentifier` is what we use for speech recognition.
enum ConversationLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish
    case french
    case german
    case portuguese
    case italian
    case japanese
    case korean
    case chineseSimplified
    case vietnamese
    case russian
    case arabic
    case hebrew
    case hindi
    case farsi
    case punjabi
    case turkish
    case urdu

    var id: String { rawValue }

    // MARK: - Display name for pickers
    var displayName: String {
        switch self {
        case .english:           return "English"
        case .spanish:           return "Spanish"
        case .french:            return "French"
        case .german:            return "German"
        case .portuguese:        return "Portuguese"
        case .italian:           return "Italian"
        case .japanese:          return "Japanese"
        case .korean:            return "Korean"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .vietnamese:        return "Vietnamese"
        case .russian:           return "Russian"
        case .arabic:            return "Arabic"
        case .hebrew:            return "Hebrew"
        case .hindi:             return "Hindi"
        case .farsi:             return "Farsi (Persian)"
        case .punjabi:           return "Punjabi"
        case .turkish:           return "Turkish"
        case .urdu:              return "Urdu"
        }
    }

    // MARK: - Azure Translator code (for translate API)
    ///
    /// These are the standard Azure language codes.
    var azureCode: String {
        switch self {
        case .english:           return "en"
        case .spanish:           return "es"
        case .french:            return "fr"
        case .german:            return "de"
        case .portuguese:        return "pt"
        case .italian:           return "it"
        case .japanese:          return "ja"
        case .korean:            return "ko"
        case .chineseSimplified: return "zh-Hans"
        case .vietnamese:        return "vi"
        case .russian:           return "ru"
        case .arabic:            return "ar"
        case .hebrew:            return "he"
        case .hindi:             return "hi"
        case .farsi:             return "fa"     // Persian/Farsi
        case .punjabi:           return "pa"
        case .turkish:           return "tr"
        case .urdu:              return "ur"
        }
    }

    // MARK: - AVSpeech voice code (spoken TTS)
    ///
    /// These are BCP-47 tags used by AVSpeechSynthesisVoice(language:).
    /// On your device:
    ///  - Many of these have real voices (en, es, fr, de, pt-BR, it, ja, ko, zh-CN, vi, ru, ar, he, hi, tr, etc.).
    ///  - Some (Farsi, Punjabi, Urdu) may NOT have native voices yet.
    ///    In that case, TextToSpeechManager logs a warning and falls back to en-US.
    ///
    /// That means:
    ///   • Translation TEXT still shows correctly in that language.
    ///   • TTS may either be silent or use an English voice – but it will NOT crash.
    var ttsCode: String {
        switch self {
        case .english:           return "en-US"
        case .spanish:           return "es-ES"
        case .french:            return "fr-FR"
        case .german:            return "de-DE"
        case .portuguese:        return "pt-BR"   // you already use BR voice
        case .italian:           return "it-IT"
        case .japanese:          return "ja-JP"
        case .korean:            return "ko-KR"
        case .chineseSimplified: return "zh-CN"
        case .vietnamese:        return "vi-VN"
        case .russian:           return "ru-RU"
        case .arabic:            return "ar-001"  // Modern Standard Arabic voice on iOS
        case .hebrew:            return "he-IL"
        case .hindi:             return "hi-IN"
        case .farsi:             return "fa-IR"   // no local voice yet on your device → falls back
        case .punjabi:           return "pa-IN"   // likely no local voice → falls back
        case .turkish:           return "tr-TR"   // Yelda voice exists
        case .urdu:              return "ur-IN"   // likely no local voice → falls back
        }
    }

    // MARK: - Speech recognition locale (what the user speaks)
    ///
    /// These are locale IDs for SFSpeechRecognizer.
    /// If a language isn’t supported for recognition on a device,
    /// you’ll get “No speech detected / not supported” style errors,
    /// but the app will keep running.
    var localeIdentifier: String {
        switch self {
        case .english:           return "en_US"
        case .spanish:           return "es_ES"
        case .french:            return "fr_FR"
        case .german:            return "de_DE"
        case .portuguese:        return "pt_BR"
        case .italian:           return "it_IT"
        case .japanese:          return "ja_JP"
        case .korean:            return "ko_KR"
        case .chineseSimplified: return "zh_CN"
        case .vietnamese:        return "vi_VN"
        case .russian:           return "ru_RU"
        case .arabic:            return "ar_SA"
        case .hebrew:            return "he_IL"
        case .hindi:             return "hi_IN"
        case .farsi:             return "fa_IR"
        case .punjabi:           return "pa_IN"
        case .turkish:           return "tr_TR"
        case .urdu:              return "ur_PK"
        }
    }
}
