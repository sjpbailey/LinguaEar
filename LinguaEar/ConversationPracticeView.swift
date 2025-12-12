//
//  ConversationPracticeView.swift
//  LinguaEar
//
//  Natural conversation partner for language practice.
//  - Understands "How do you say ...?"
//  - Gives Spanish translation
//  - Speaks it (using TTS)
//  - Lets you repeat and scores you
//  - After 3 low scores, shows word breakdown
//

import SwiftUI

struct ConversationPracticeView: View {
    
    enum Speaker {
        case you
        case partner
    }
    
    struct Message: Identifiable {
        let id = UUID()
        let speaker: Speaker
        let text: String
    }
    
    // MARK: - Dependencies
    
    let nativeLanguage: ConversationLanguage      // e.g. .english
    let targetLanguage: ConversationLanguage      // e.g. .spanish
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var translator      = TranslatorService()
    @StateObject private var ttsManager      = TextToSpeechManager()
    
    // MARK: - Conversation State
    
    @State private var messages: [Message] = []
    @State private var isListening: Bool = false
    @State private var statusText: String = "Tap the mic and start speaking."
    
    // When user asks "How do you say ...", we store the expected phrase:
    @State private var currentExpectedPhrase: String? = nil
    @State private var attemptsOnCurrentPhrase: Int = 0
    @State private var lastScore: Int? = nil
    @State private var lastFeedback: String = ""
    
    // Word breakdown after repeated difficulty
    @State private var showBreakdown: Bool = false
    
    // Playback speed (reuse turtle / rabbit style: 0.45 slow, 0.9 normal)
    @State private var playbackSpeed: Float = 0.9   // default slightly under normal
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Conversation Practice")
                        .font(.title2).bold()
                    Text("Talk to a natural \(targetLanguage.displayName) partner. Try asking: “How do you say … ?”")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Conversation scroll
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.speaker == .you {
                                    Spacer()
                                    Text(msg.text)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.15))
                                        .cornerRadius(10)
                                } else {
                                    Text(msg.text)
                                        .padding(8)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(10)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                
                // Status text
                Text(statusText)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // If we have an expected phrase, show it + breakdown
                if let expected = currentExpectedPhrase {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current phrase in \(targetLanguage.displayName):")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(expected)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        if let score = lastScore {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last pronunciation score: \(score)%")
                                    .font(.subheadline)
                                Text(lastFeedback)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        
                        if showBreakdown {
                            Text("Word breakdown:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            let words = breakdownWords(expected)
                            
                            WrapWordsView(words: words)
                        }
                    }
                }
                
                // Playback speed selector
                HStack {
                    Text("Partner speed:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button(action: { playbackSpeed = 0.45 }) {
                        Label("Slow", systemImage: playbackSpeed == 0.45 ? "tortoise.fill" : "tortoise")
                            .foregroundColor(playbackSpeed == 0.45 ? .blue : .primary)
                    }
                    
                    Spacer().frame(width: 16)
                    
                    Button(action: { playbackSpeed = 0.9 }) {
                        Label("Normal", systemImage: playbackSpeed == 0.9 ? "hare.fill" : "hare")
                            .foregroundColor(playbackSpeed == 0.9 ? .blue : .primary)
                    }
                    
                    Spacer()
                }
                .font(.caption)
                
                // Mic button
                VStack(spacing: 6) {
                    Button {
                        toggleListening()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isListening ? Color.red : Color.green)
                                .frame(width: 80, height: 80)
                                .shadow(radius: isListening ? 8 : 4)
                            
                            Image(systemName: isListening ? "mic.fill" : "mic")
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .bold))
                        }
                    }
                    
                    Text(isListening ? "Listening… tap to stop" : "Tap to speak")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: speechRecognizer.transcript) { _, newValue in
                if isListening {
                    // live update status if you want later
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleListening() {
        if isListening {
            stopListeningAndHandle()
        } else {
            startListening()
        }
    }
    
    private func startListening() {
        lastScore = nil
        lastFeedback = ""
        statusText = "Speak now…"
        isListening = true
        
        speechRecognizer.startTranscribing(
            localeIdentifier: nativeLanguage.localeIdentifier
        )
    }
    
    private func stopListeningAndHandle() {
        isListening = false
        speechRecognizer.stopTranscribing()
        
        let raw = speechRecognizer.transcript
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !raw.isEmpty else {
            statusText = "I didn’t catch anything. Try again."
            return
        }
        
        addMessage(.you, text: raw)
        
        handleUserUtterance(raw)
    }
    
    private func addMessage(_ speaker: Speaker, text: String) {
        messages.append(Message(speaker: speaker, text: text))
    }
    
    // MARK: - Main logic
    
    private func handleUserUtterance(_ text: String) {
        let lower = text.lowercased()
        
        // Case 1: "How do you say ... in Spanish?"
        if lower.contains("how do you say") {
            handleHowDoYouSay(text)
            return
        }
        
        // Case 2: user is trying to repeat the current phrase
        if let expected = currentExpectedPhrase {
            scorePronunciation(expected: expected, actual: text)
            return
        }
        
        // Case 3: generic small talk – echo, translate, reply naturally
        handleGenericConversation(text)
    }
    
    private func handleHowDoYouSay(_ text: String) {
        // naive extraction: get text after "how do you say"
        let lower = text.lowercased()
        guard let range = lower.range(of: "how do you say") else {
            statusText = "I’ll try, but I didn’t quite catch the phrase."
            return
        }
        
        var phrasePart = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove leading "in Spanish" etc if present
        if let inRange = phrasePart.lowercased().range(of: "in spanish") {
            phrasePart = phrasePart[..<inRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Strip surrounding quotes if user said “..."”
        phrasePart = phrasePart.trimmingCharacters(in: CharacterSet(charactersIn: "\"“”'"))
        
        let englishPhrase = String(phrasePart)
        guard !englishPhrase.isEmpty else {
            statusText = "Tell me the phrase you want to learn, for example: “How do you say ‘Where is the bathroom?’ in Spanish?”"
            return
        }
        
        // 🔐 Daily limit check if this uses Translation API
        let allowed = DailyLimitManager.shared.consumeOneIfAvailable()
        guard allowed else {
            statusText = "Daily translation limit reached for this device."
            addMessage(.partner, text: "Lo siento, has alcanzado el límite diario de traducciones en este dispositivo.")
            return
        }
        
        statusText = "Translating your phrase…"
        
        translator.translate(
            text: englishPhrase,
            from: nativeLanguage.azureCode,
            to:   targetLanguage.azureCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    self.currentExpectedPhrase = translated
                    self.attemptsOnCurrentPhrase = 0
                    self.showBreakdown = false
                    self.lastScore = nil
                    self.lastFeedback = ""
                    
                    let reply = """
                    In \(self.targetLanguage.displayName), you can say:
                    “\(translated)”
                    
                    Try repeating it now.
                    """
                    self.addMessage(.partner, text: reply)
                    
                    self.statusText = "Listen carefully and then repeat."
                    
                    // Speak the phrase in the target language, using chosen speed
                    self.ttsManager.speakWithRate(
                        translated,
                        languageCode: self.targetLanguage.ttsCode,
                        rate: self.playbackSpeed,
                        useSpeaker: false
                    )
                    
                case .failure(let error):
                    self.addMessage(.partner, text: "I had trouble translating that: \(error.localizedDescription)")
                    self.statusText = "Translation error."
                }
            }
        }
    }
    
    private func handleGenericConversation(_ text: String) {
        // For now, very simple: translate what the user said to target language
        // and respond with a friendly echo + a small phrase.
        
        let allowed = DailyLimitManager.shared.consumeOneIfAvailable()
        guard allowed else {
            statusText = "Daily translation limit reached for this device."
            addMessage(.partner, text: "Lo siento, has alcanzado el límite diario de traducciones en este dispositivo.")
            return
        }
        
        statusText = "Thinking in \(targetLanguage.displayName)…"
        
        translator.translate(
            text: text,
            from: nativeLanguage.azureCode,
            to:   targetLanguage.azureCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    let reply = """
                    I might say:
                    “\(translated)”
                    
                    Try saying that back to me.
                    """
                    self.addMessage(.partner, text: reply)
                    self.statusText = "Repeat the phrase if you like."
                    
                    self.currentExpectedPhrase = translated
                    self.attemptsOnCurrentPhrase = 0
                    self.showBreakdown = false
                    self.lastScore = nil
                    self.lastFeedback = ""
                    
                    self.ttsManager.speakWithRate(
                        translated,
                        languageCode: self.targetLanguage.ttsCode,
                        rate: self.playbackSpeed,
                        useSpeaker: false
                    )
                    
                case .failure(let error):
                    self.addMessage(.partner, text: "I couldn’t quite handle that: \(error.localizedDescription)")
                    self.statusText = "Error."
                }
            }
        }
    }
    
    // MARK: - Pronunciation scoring
    
    private func scorePronunciation(expected: String, actual: String) {
        attemptsOnCurrentPhrase += 1
        
        let score = similarityScore(expected: expected, actual: actual)
        lastScore = score
        lastFeedback = feedback(for: score, expected: expected)
        
        statusText = "Score: \(score)% — \(lastFeedback)"
        
        addMessage(.partner, text: "I heard: “\(actual)”\nScore: \(score)% — \(lastFeedback)")
        
        if attemptsOnCurrentPhrase >= 3 && score < 80 {
            showBreakdown = true
        }
    }
    
    private func normalize(_ s: String) -> [String] {
        s.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
    
    /// Very simple word-overlap score 0–100
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
            return "Excellent! That sounded very clear."
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
    
    private func breakdownWords(_ phrase: String) -> [String] {
        normalize(phrase)
    }
}

// Simple view to show words in “chips”
struct WrapWordsView: View {
    let words: [String]
    
    var body: some View {
        // Basic wrap using flexible grid
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 4)], spacing: 4) {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
        }
    }
}
