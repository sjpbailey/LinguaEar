//
//  TextToSpeechManager.swift
//  LinguaEar
//

import Foundation
import AVFoundation

final class TextToSpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    private static var didDumpVoices = false

    func speak(_ text: String, languageCode: String, useSpeaker: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

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

            #if os(watchOS)
            #else
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

        if let voice = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = voice
            print("✅ Using TTS voice: \(voice.language) – \(voice.name)")
        } else {
            let fallbackLanguage = "en-US"
            utterance.voice = AVSpeechSynthesisVoice(language: fallbackLanguage)
            print("⚠️ No TTS voice for \(languageCode). Falling back to \(fallbackLanguage).")
        }

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    /// Speak the text with adjustable speed (0.2 = very slow, 0.7 = upper-normal)
    func speakWithRate(_ text: String,
                       languageCode: String,
                       rate: Float,
                       useSpeaker: Bool = false) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback,
                                    mode: .spokenAudio,
                                    options: [.duckOthers])
            try session.setActive(true)

            #if os(watchOS)
            #else
            if useSpeaker {
                try session.overrideOutputAudioPort(.speaker)
            } else {
                try session.overrideOutputAudioPort(.none)
            }
            #endif

        } catch {
            print("Audio session error (rate): \(error.localizedDescription)")
        }

        let utterance = AVSpeechUtterance(string: trimmed)

        // Clamp to a nice human range: slower floor + no helium top
        let safeRate = max(0.2, min(rate, 0.7))
        utterance.rate = safeRate

        if let voice = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = voice
        }

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
