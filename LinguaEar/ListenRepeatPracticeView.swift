//  ListenRepeatPracticeView.swift
//  LinguaEar
//

import SwiftUI
import AVFoundation

struct ListenRepeatPracticeView: View {
    
    // MARK: - Types
    
    struct PracticePhrase: Identifiable {
        let id = UUID()
        let english: String
        let spanish: String
    }
    
    enum PracticeState {
        case idle
        case playing
        case listening
        case scored
    }
    
    // MARK: - Dependencies
    
    let practiceLanguage: ConversationLanguage   // usually “They hear”
    let translator: TranslatorService            // translate EN → target
    let presetEnglishPhrases: [String]
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var ttsManager       = TextToSpeechManager()
    
    // MARK: - Audio state
    
    @State private var playbackSpeed: Float = 0.50   // 0.25 slow, 0.50 normal
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var userRecordingURL: URL?
    
   
    // MARK: - UI state
    
    @State private var currentIndex: Int = 0
    @State private var practiceState: PracticeState = .idle
    
    @State private var recognizedText: String = ""
    @State private var statusText: String = "Tap Listen to hear the phrase."
    
    @State private var score: Int? = nil
    @State private var feedbackText: String = ""
    @State private var attemptsForCurrent: Int = 0
    
    // Custom phrase (learner types in English)
    @State private var customEnglishText: String = ""
    @State private var customTargetText: String = ""
    @State private var usingCustomPhrase: Bool   = false
    @State private var isTranslatingCustom: Bool = false
    @FocusState private var customPhraseFocused: Bool
    
    // ✅ NEW: preset phrase translations cached by phrase index (EN → target)
    @State private var presetTranslatedByIndex: [Int: String] = [:]
    
    // MARK: - Derived helpers (no logic directly in body)
    
    private var effectiveEnglish: String {
        guard !presetEnglishPhrases.isEmpty else { return "" }
        if usingCustomPhrase,
           !customEnglishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return customEnglishText
        }
        return presetEnglishPhrases[currentIndex]
    }
    
    private var effectiveTarget: String {
        if usingCustomPhrase,
           !customTargetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return customTargetText
        }

        if let cached = presetTranslatedByIndex[currentIndex],
           !cached.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return cached
        }

        return presetEnglishPhrases[currentIndex] // until translation arrives
    }
    
    private var phraseLabel: String {
        if usingCustomPhrase {
            return "Custom phrase"
        } else {
            return presetEnglishPhrases[currentIndex]
        }
    }
    
    private var wordTokens: [String] {
        effectiveTarget
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    headerSection
                    
                    customPhraseSection
                    
                    phraseSection
                    
                    statusSection
                    
                    speedSection
                    
                    listenRepeatButtons
                    
                    recognizedSection
                    
                    bottomRow
                }
                .padding()
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                playbackSpeed = 0.50
                translatePresetIfNeeded()
            }
            .onChange(of: currentIndex) { _, _ in
                translatePresetIfNeeded()
            }
            .onChange(of: practiceLanguage) { _, _ in
                translatePresetIfNeeded()
            }
            .onDisappear {
                speechRecognizer.stopTranscribing()
                audioRecorder?.stop()
                audioPlayer?.stop()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Listen & Repeat")
                .font(.title2).bold()
            Text("Practice speaking \(practiceLanguage.displayName).")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var customPhraseSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom practice phrase (optional)")
                .font(.subheadline)
            
            Text("Type a phrase in English to practice it in \(practiceLanguage.displayName).")
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField("Type your own phrase here…", text: $customEnglishText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
                .focused($customPhraseFocused)
                .submitLabel(.done)
            
            HStack(spacing: 12) {
                Button {
                    applyCustomPhrase()
                } label: {
                    HStack(spacing: 6) {
                        if isTranslatingCustom {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text("Use this phrase")
                    }
                    .frame(maxWidth: .infinity, minHeight: 36)
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(
                    customEnglishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isTranslatingCustom
                )
                
                if usingCustomPhrase {
                    Button(role: .destructive) {
                        clearCustomPhrase()
                    } label: {
                        Text("Clear")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        goToNextPhrase()
                    } label: {
                        Text("Next phrase")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                }
            }
        }
    }
    
    private var phraseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(phraseLabel)
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(effectiveTarget)
                    .font(.title3)
                    .bold()
                Text(effectiveEnglish)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            HStack {
                Button {
                    copyPracticePhrase()
                } label: {
                    Label("Copy phrase", systemImage: "doc.on.doc")
                }
                .font(.caption)
                
                Spacer()
            }
            
            if !wordTokens.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tap a word to hear it slowly")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 80), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(wordTokens, id: \.self) { word in
                            Button {
                                ttsManager.speakWithRate(
                                    word,
                                    languageCode: practiceLanguage.ttsCode,
                                    rate: 0.25,
                                    useSpeaker: false
                                )
                            } label: {
                                Text(word)
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.top, 6)
            }
        }
    }
    
    private var statusSection: some View {
        Text(statusText)
            .font(.footnote)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var speedSection: some View {
        HStack {
            Text("Speed:")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: { playbackSpeed = 0.25 }) {
                Label("Slow", systemImage: playbackSpeed == 0.25 ? "tortoise.fill" : "tortoise")
                    .foregroundColor(playbackSpeed == 0.25 ? .blue : .primary)
            }
            
            Spacer().frame(width: 16)
            
            Button(action: { playbackSpeed = 0.50 }) {
                Label("Normal", systemImage: playbackSpeed == 0.50 ? "hare.fill" : "hare")
                    .foregroundColor(playbackSpeed == 0.50 ? .blue : .primary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var listenRepeatButtons: some View {
        VStack(spacing: 8) {
            Text("Tip: Repeat • wait • speak • wait • Stop")
                .font(.caption2)
                .foregroundColor(.blue.opacity(0.75))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(practiceState == .listening ? 1 : 0)
                .frame(height: 18)
            
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Button { playCurrentPhrase() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 70, height: 70)
                                .shadow(radius: 4)
                            
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 26, weight: .bold))
                        }
                    }
                    Text("Listen")
                        .font(.caption)
                }
                
                VStack(spacing: 8) {
                    Button { toggleListening() } label: {
                        ZStack {
                            Circle()
                                .fill(practiceState == .listening ? Color.red : Color.green)
                                .frame(width: 70, height: 70)
                                .shadow(radius: practiceState == .listening ? 8 : 4)
                            
                            Image(systemName: practiceState == .listening ? "mic.fill" : "mic")
                                .foregroundColor(.white)
                        }
                    }
                    Text(practiceState == .listening ? "Tap to stop" : "Repeat")
                        .font(.caption)
                }
            }
        }
        .padding(.top, 4)
    }
    
    private var recognizedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What I heard:")
                .font(.subheadline)
            Text(recognizedText.isEmpty ? "…" : recognizedText)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            if let score {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Score: \(score)%")
                            .font(.headline)
                        Text(feedbackText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
        }
    }
    
    private var bottomRow: some View {
        HStack {
            Spacer()
            Text("Attempts: \(attemptsForCurrent)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Preset translation (NEW)
    
    private func translatePresetIfNeeded() {
        // Only for preset phrases (not custom)
        if usingCustomPhrase { return }        
        
        // Already cached?
        if let cached = presetTranslatedByIndex[currentIndex],
           !cached.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        let english = presetEnglishPhrases[currentIndex]
        
        translator.translate(
            text: english,
            from: ConversationLanguage.english.azureCode,
            to: practiceLanguage.azureCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    self.presetTranslatedByIndex[self.currentIndex] = translated
                case .failure:
                    // Do nothing (we'll keep showing English)
                    break
                }
            }
        }
    }
    
    // MARK: - Custom phrase
    
    private func applyCustomPhrase() {
        let trimmed = customEnglishText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isTranslatingCustom = true
        statusText = "Translating custom phrase…"
        
        translator.translate(
            text: trimmed,
            from: ConversationLanguage.english.azureCode,
            to:   practiceLanguage.azureCode
        ) { result in
            DispatchQueue.main.async {
                self.isTranslatingCustom = false
                switch result {
                case .success(let translated):
                    self.customTargetText = translated
                    self.usingCustomPhrase = true
                    self.resetForNewPhrase()
                    self.statusText = "Custom phrase ready. Tap Listen to hear it."
                    self.customPhraseFocused = false
                case .failure(let error):
                    self.statusText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func clearCustomPhrase() {
        customEnglishText = ""
        customTargetText  = ""
        usingCustomPhrase = false
        resetForNewPhrase()
        statusText = "Tap Listen to hear the phrase."
        
        // ✅ When returning to presets, ensure preset translation exists
        translatePresetIfNeeded()
    }
    
    private func resetForNewPhrase() {
        recognizedText = ""
        score          = nil
        feedbackText   = ""
        attemptsForCurrent = 0
        practiceState  = .idle
    }
    
    // MARK: - Actions
    
    private func playCurrentPhrase() {
        let target = effectiveTarget
        statusText = "Listening to the phrase…"
        
        ttsManager.speakWithRate(
            target,
            languageCode: practiceLanguage.ttsCode,
            rate: playbackSpeed,
            useSpeaker: false
        )
        
        practiceState = .playing
    }
    
    private func toggleListening() {
        switch practiceState {
        case .listening:
            stopListeningAndScore()
        default:
            startListening()
        }
    }
    
    private func startListening() {
        recognizedText = ""
        score          = nil
        feedbackText   = ""
        statusText     = "Speak the phrase now…"
        practiceState  = .listening
        attemptsForCurrent += 1
        
        speechRecognizer.stopTranscribing()
        speechRecognizer.reset()
        
        speechRecognizer.startTranscribing(
            localeIdentifier: practiceLanguage.localeIdentifier
        )
    }
    
    private func stopListeningAndScore() {
        practiceState = .idle
        
        speechRecognizer.stopTranscribing()
        
        let raw = speechRecognizer.transcript
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        recognizedText = raw
        
        let expected = effectiveTarget
        
        let s = similarityScore(expected: expected, actual: raw)
        score = s
        feedbackText = feedback(for: s, expected: expected)
        
        statusText = "Score: \(s)% — \(feedbackText)"
        practiceState = .scored
        
        speechRecognizer.reset()
    }
    
    private func goToNextPhrase() {
        speechRecognizer.stopTranscribing()
        audioRecorder?.stop()
        audioPlayer?.stop()
        
        usingCustomPhrase = false
        customEnglishText = ""
        customTargetText  = ""
        
        recognizedText = ""
        score          = nil
        feedbackText   = ""
        attemptsForCurrent = 0
        userRecordingURL   = nil
        
        currentIndex = (currentIndex + 1) % presetEnglishPhrases.count
        practiceState = .idle
        statusText = "Tap Listen to hear the next phrase."
        
        // ✅ Ensure next preset has translation if needed
        translatePresetIfNeeded()
    }
    
    private func copyPracticePhrase() {
        let text = effectiveTarget.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        UIPasteboard.general.string = text
        statusText = "Copied phrase to clipboard."
    }
    
    // MARK: - Recording (unchanged / currently unused)
    
    private func recordingURL() -> URL {
        let temp = FileManager.default.temporaryDirectory
        return temp.appendingPathComponent("linguaear_practice.m4a")
    }
    
    private func startRecording() {
        let url = recordingURL()
        try? FileManager.default.removeItem(at: url)
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.defaultToSpeaker, .duckOthers])
            try session.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder = recorder
            userRecordingURL = url
            
            recorder.prepareToRecord()
            _ = recorder.record()
            
        } catch {
            print("🎙 Recording error: \(error.localizedDescription)")
            userRecordingURL = nil
            audioRecorder = nil
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    // MARK: - Scoring
    
    private func normalize(_ s: String) -> [String] {
        s.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
    
    private func similarityScore(expected: String, actual: String) -> Int {
        let expWords = normalize(expected)
        let actWords = normalize(actual)
        
        guard !expWords.isEmpty else { return 0 }
        guard !actWords.isEmpty else { return 0 }
        
        var matches = 0
        for w in expWords {
            if actWords.contains(w) {
                matches += 1
            }
        }
        let ratio = Double(matches) / Double(expWords.count)
        return Int((ratio * 100).rounded())
    }
    
    private func feedback(for score: Int, expected: String) -> String {
        switch score {
        case 90...100:
            return "Perfect! That’s very clear."
        case 75..<90:
            return "Very good — just polish the pronunciation a little."
        case 50..<75:
            return "Pretty close. Listen again and focus on the stressed syllables."
        case 1..<50:
            return "Not quite. Try repeating more slowly and clearly."
        default:
            return "I couldn’t really match that to “\(expected)”. Let’s try again."
        }
    }
}
