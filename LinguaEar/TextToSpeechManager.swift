//
//  TextToSpeechManager.swift
//  LinguaEar
//

import Foundation
import AVFoundation

final class TextToSpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    /// Only dump all voices once, on first use.
    private static var didDumpVoices = false

    /// Speak `text` in a given language (e.g. "en-US", "es-ES", "fa-IR").
    /// If `useSpeaker` is true, we ask iOS to use the loudspeaker (iOS only).
    func speak(_ text: String, languageCode: String, useSpeaker: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Debug: dump available voices once
        if !Self.didDumpVoices {
            Self.didDumpVoices = true
            let voices = AVSpeechSynthesisVoice.speechVoices()
            print("🔊 Available TTS voices (\(voices.count)):")
            for v in voices {
                print("  • \(v.language) – \(v.name)")
            }
        }

        print("🔊 TTS requested languageCode = \(languageCode)")

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback,
                                    mode: .spokenAudio,
                                    options: [.duckOthers])
            try session.setActive(true)

            // -------------------------------
            // PLATFORM-SAFE SPEAKER HANDLING
            // -------------------------------
            #if os(watchOS)
            // WATCH DOES NOT SUPPORT speaker routing
            // No overrideOutputAudioPort on watchOS
            #else
            // iOS – original behavior (unchanged)
            if useSpeaker {
                try session.overrideOutputAudioPort(.speaker)
            } else {
                try session.overrideOutputAudioPort(.none)
            }
            #endif

        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        // Try to use the requested language (e.g. "fa-IR" for Farsi).
        if let voice = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = voice
            print("✅ Using TTS voice: \(voice.language) – \(voice.name)")
        } else {
            // Fallback if the device has no native voice for that language.
            let fallbackLanguage = "en-US"
            utterance.voice = AVSpeechSynthesisVoice(language: fallbackLanguage)
            print("⚠️ No TTS voice for \(languageCode). Falling back to \(fallbackLanguage).")
        }

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
