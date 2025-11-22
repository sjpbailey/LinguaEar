//
//  SpeechRecognizer.swift
//  LinguaEar
//

import Foundation
import AVFoundation
import Speech

final class SpeechRecognizer: ObservableObject {

    /// Latest recognized text (live updated while you talk)
    @Published var transcript: String = ""

    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?

    init() {
        // Ask for permission once when the object is created
        SFSpeechRecognizer.requestAuthorization { status in
            print("Speech auth status: \(status.rawValue)")
        }
    }

    /// Clear any previous transcript
    func reset() {
        transcript = ""
    }

    /// Start listening in the given locale (e.g. "en-US", "es-MX").
    func startTranscribing(localeIdentifier: String) {
        // Stop any existing session first
        stopTranscribing()
        transcript = ""

        // Set up recognizer for the chosen language
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            DispatchQueue.main.async {
                self.transcript = "Speech recognizer not available for \(localeIdentifier)"
            }
            return
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record,
                                         mode: .measurement,
                                         options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.transcript = "Audio session error: \(error.localizedDescription)"
            }
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            DispatchQueue.main.async {
                self.transcript = "Couldn't start audio engine: \(error.localizedDescription)"
            }
            return
        }

        recognitionTask = recognizer.recognitionTask(with: request!) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
            }
        }
    }

    /// Stop listening and clean everything up.
    func stopTranscribing() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
    }
}
