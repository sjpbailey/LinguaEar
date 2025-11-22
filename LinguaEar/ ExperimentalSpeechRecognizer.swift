//
//  ExperimentalSpeechRecognizer.swift
//  LinguaEar
//
//  Experimental version of speech recognition with simple
//  "phrase detection" using pauses in the transcript.
//  Your original SpeechRecognizer.swift stays as the stable version.
//

import Foundation
import AVFoundation
import Speech

final class ExperimentalSpeechRecognizer: ObservableObject {

    /// Live running transcript (everything the user has said in this session).
    @Published var transcript: String = ""

    /// Callback: fires whenever we detect a "new phrase" based on a short pause.
    /// The string passed in is ONLY the *new* chunk since the last phrase.
    var onPhraseDetected: ((String) -> Void)?

    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?

    /// Keep track of the transcript we've already sent out as "phrases".
    private var lastHandledText: String = ""

    /// Timer used to detect pauses (no transcript changes).
    private var pauseTimer: Timer?

    init() {
        // Ask for permission once when the object is created
        SFSpeechRecognizer.requestAuthorization { status in
            print("ExperimentalSpeechRecognizer auth status: \(status.rawValue)")
        }
    }

    /// Clear any previous transcript and phrase state.
    func reset() {
        transcript = ""
        lastHandledText = ""
        cancelPauseTimer()
    }

    // MARK: - Public API

    /// Start listening in the given locale (e.g. "en-US", "es-MX").
    func startTranscribing(localeIdentifier: String) {
        // Stop any existing session first
        stopTranscribing()
        reset()

        // Set up recognizer for the chosen language
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            DispatchQueue.main.async {
                self.transcript = "Speech recognizer not available for \(localeIdentifier)"
            }
            return
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        // We want partials so we can react as user is speaking.
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
                    // Update the full running transcript.
                    self.transcript = result.bestTranscription.formattedString
                    // Restart the pause timer every time we get a new partial.
                    self.schedulePauseCheck()
                }
            }

            if let error = error {
                print("ExperimentalSpeechRecognizer error: \(error.localizedDescription)")
            }
        }
    }

    /// Stop listening and clean everything up.
    func stopTranscribing() {
        cancelPauseTimer()

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil

        // When we fully stop, emit any remaining text as a final phrase.
        emitNewPhraseIfAny()
    }

    // MARK: - Pause / phrase detection

    /// Cancel any existing pause timer.
    private func cancelPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = nil
    }

    /// Whenever the transcript changes, we call this.
    /// It waits a short time (e.g. 1.2 seconds) with no further changes.
    /// If nothing new comes in, we treat the new text as a "phrase".
    private func schedulePauseCheck() {
        cancelPauseTimer()

        // Adjust this interval if needed:
        let interval: TimeInterval = 1.2

        pauseTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.emitNewPhraseIfAny()
        }

        // Ensure the timer runs on the main run loop.
        RunLoop.main.add(pauseTimer!, forMode: .common)
    }

    /// Compare the current transcript to what we've already emitted.
    /// If there's new text, treat it as a phrase and notify via onPhraseDetected.
    private func emitNewPhraseIfAny() {
        cancelPauseTimer()

        let full = transcript.trimmingCharacters(in: .whitespacesAndNewlines)

        guard full.count > lastHandledText.count else { return }

        // New part since last phrase.
        let startIndex = full.index(full.startIndex, offsetBy: lastHandledText.count)
        let newSegment = full[startIndex...]
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !newSegment.isEmpty else { return }

        lastHandledText = full

        // Notify the listener (e.g. your AutoResponseContentView)
        onPhraseDetected?(String(newSegment))
    }
}
