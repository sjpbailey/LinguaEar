//
//  ContentView.swift
//  LinguaEar
//
//  Auto-response experimental main view
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    // MARK: - Managers
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var translator      = TranslatorService()
    @StateObject private var ttsManager      = TextToSpeechManager()
    
    // MARK: - UI state
    @State private var isListening: Bool      = false
    @State private var statusMessage: String  = "Idle"
    @State private var heardPhrase: String    = ""
    @State private var translatedText: String = ""
    
    /// Track whether the mic button is currently being held down (walkie-talkie mode)
    @State private var isPressingMic: Bool    = false
    
    /// Auto-response “session” flag (we can expand on this later)
    @State private var isAutoSessionActive: Bool = false
    
    /// Auto-stop timer for auto-response mode (silence detection)
    @State private var silenceWorkItem: DispatchWorkItem? = nil
    
    // MARK: - Language selection
    @State private var theyLanguage: ConversationLanguage = .spanish
    @State private var youLanguage:  ConversationLanguage = .english
    @State private var showDailyLimitAlert = false
    
    /// When true, we let the translator auto-detect the text language
    @State private var autoDetectLanguage: Bool = false
    /// When true, we experiment with Auto-response session mode.
    @State private var autoResponseMode: Bool = false
    @State private var showHoldTip: Bool = false
    @State private var holdTipWorkItem: DispatchWorkItem? = nil
    
    // MARK: - Sheets
    enum ActiveSheet: Identifiable {
        case listenRepeat
        
        var id: Int { hashValue }
    }
    
    @State private var activeSheet: ActiveSheet?
    
    // MARK: - Conversation direction
    enum TalkDirection {
        case youToThem
        case themToYou
    }
    
    @State private var conversationDirection: TalkDirection = .youToThem
    
    // MARK: - Quick phrase categories
    enum PhraseCategory: String, CaseIterable, Identifiable {
        case basic        = "Basic"
        case travel       = "Travel"
        case salon        = "Salon"
        case conversation = "Conversation"
        
        var id: String { rawValue }
    }
    
    // MARK: - Travel subcategories
    enum TravelSubcategory: String, CaseIterable, Identifiable {
        case taxi       = "Taxi"
        case bus        = "Bus"
        case train      = "Train"
        case airport    = "Airport"
        case navigation = "Directions"
        case food       = "Food & Restaurants"
        case shopping   = "Shopping"
        case hotel      = "Hotel"
        case emergency  = "Emergencies"
        case basics     = "Basics"
        
        var id: String { rawValue }
    }
    
    // MARK: - Category phrases (non-travel)
    private let phrasesByCategory: [PhraseCategory: [String]] = [
        .basic: [
            "Hello, how are you?",
            "Nice to meet you.",
            "What is your name?",
            "Can you say that again?",
            "Can you speak more slowly, please?",
            "I’m learning your language.",
            "Thank you very much.",
            "Excuse me, can you help me?",
            "I don’t understand."
        ],
        
        .salon: [
            "I would like a haircut, please.",
            "Just a little shorter, please.",
            "Not too short on top.",
            "Please trim the sides.",
            "Can you wash my hair, please?",
            "Can you shave the neck?",
            "It looks great, thank you!"
        ],
        
        .conversation: [
            "What do you think?",
            "Can we talk for a moment?",
            "That’s interesting!",
            "I really appreciate your help."
        ]
    ]
    
    // MARK: - Travel phrases by subcategory
    private let travelPhrasesBySubcategory: [TravelSubcategory: [String]] = [
        .taxi: [
            "Where can I find a taxi?",
            "I need a taxi, please.",
            "Can you call a taxi for me?",
            "How long will the taxi take to arrive?",
            "How much is the fare?",
            "Please take me here.",
            "Can you wait for me?"
        ],
        
        .bus: [
            "Where is the bus stop?",
            "Which bus goes to the city center?",
            "What time is the next bus?",
            "Does this bus stop at ____?",
            "How much is a bus ticket?"
        ],
        
        .train: [
            "Where is the train station?",
            "Which platform is the train on?",
            "When is the next train?",
            "Does this train stop at ____?",
            "How much is a train ticket?",
            "I would like to buy a train ticket."
        ],
        
        .airport: [
            "Where is the airport?",
            "Where is the check-in counter?",
            "Where is security?",
            "Where is my boarding gate?",
            "What time does boarding start?",
            "Where do I pick up my luggage?",
            "My bag is missing. Can you help me?",
            "I need assistance with my passport."
        ],
        
        .navigation: [
            "I need directions, please.",
            "How do I get to the city center?",
            "Can you show me on the map?",
            "Is it far from here?",
            "Is it walking distance?",
            "Which way do I go?"
        ],
        
        .food: [
            "Where is the nearest restaurant?",
            "Can you recommend a good place to eat?",
            "Do you take credit cards?",
            "Is there a vegetarian option?",
            "I would like a table for two."
        ],
        
        .shopping: [
            "How much does this cost?",
            "Do you have this in another size?",
            "Do you have this in another color?",
            "Can I try this on?",
            "Is there a discount?"
        ],
        
        .hotel: [
            "Where is the hotel reception?",
            "I have a reservation.",
            "Can I check in early?",
            "What time is checkout?",
            "Can you hold my luggage?",
            "How do I connect to the Wi-Fi?"
        ],
        
        .emergency: [
            "I need help!",
            "Please call an ambulance!",
            "Please call the police!",
            "I lost my passport.",
            "I lost my wallet.",
            "I am lost. Can you help me?"
        ],
        
        .basics: [
            "Where is the bathroom?",
            "Do you speak English?",
            "Can you speak more slowly?",
            "I don't understand.",
            "Can you repeat that?"
        ]
    ]
    
    @State private var selectedCategory: PhraseCategory   = .basic
    @State private var selectedPhraseIndex: Int           = 0
    @State private var showPhrases: Bool                  = false
    @State private var selectedTravelSubcategory: TravelSubcategory = .taxi
    
    // MARK: - Computed helpers (to make compiler happy)
    
    private var directionSummary: String {
        switch conversationDirection {
        case .youToThem:
            if autoDetectLanguage {
                return "You speak (auto-detect), they hear \(theyLanguage.displayName)."
            } else {
                return "You speak \(youLanguage.displayName), they hear \(theyLanguage.displayName)."
            }
        case .themToYou:
            if autoDetectLanguage {
                return "They speak (auto-detect), you hear \(youLanguage.displayName)."
            } else {
                return "They speak \(theyLanguage.displayName), you hear \(youLanguage.displayName)."
            }
        }
    }
    
    private var playLanguageName: String {
        switch conversationDirection {
        case .youToThem:
            return theyLanguage.displayName
        case .themToYou:
            return youLanguage.displayName
        }
    }
    
    private var playTTSCode: String {
        switch conversationDirection {
        case .youToThem:
            return theyLanguage.ttsCode
        case .themToYou:
            return youLanguage.ttsCode
        }
    }
    
    private var micLabel: String {
        if autoResponseMode {
            return isListening
            ? "Listening… stop talking to auto-translate"
            : "Tap to speak (auto-response)"
        } else {
            return isListening
            ? "Release to translate & speak"
            : "Hold to speak"
        }
    }
    
    private var v1PracticePhrases: [String] {
        var out: [String] = []

        // Basic
        out += phrasesByCategory[.basic] ?? []

        // Travel (in enum order)
        out += travelPhrasesBySubcategory[.taxi] ?? []
        out += travelPhrasesBySubcategory[.bus] ?? []
        out += travelPhrasesBySubcategory[.train] ?? []
        out += travelPhrasesBySubcategory[.airport] ?? []
        out += travelPhrasesBySubcategory[.navigation] ?? []
        out += travelPhrasesBySubcategory[.food] ?? []
        out += travelPhrasesBySubcategory[.shopping] ?? []
        out += travelPhrasesBySubcategory[.hotel] ?? []
        out += travelPhrasesBySubcategory[.emergency] ?? []
        out += travelPhrasesBySubcategory[.basics] ?? []

        // Salon
        out += phrasesByCategory[.salon] ?? []

        // Conversation (last)
        out += phrasesByCategory[.conversation] ?? []

        return out
    }
    
    private var quickPhrases: [String] {
        if selectedCategory == .travel {
            return travelPhrasesBySubcategory[selectedTravelSubcategory] ?? []
        } else {
            return phrasesByCategory[selectedCategory] ?? []
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                // TITLE + STATUS IN ONE ROW
                HStack(alignment: .center) {
                    
                    Text("LinguaEar")
                        .font(.system(size: 32, weight: .bold))
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: isListening ? "waveform.circle.fill" : "waveform.circle")
                            .foregroundColor(isListening ? .red : .gray)
                            .font(.system(size: 18))
                        
                        Text(statusMessage)
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                .padding(.top, 16)
                
                // Language pickers + swap
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("They hear")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Picker("", selection: $theyLanguage) {
                            ForEach(ConversationLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Spacer()
                    
                    Button(action: swapLanguages) {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.system(size: 34))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You speak")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Picker("", selection: $youLanguage) {
                            ForEach(ConversationLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Auto-detect toggle
                Toggle(isOn: $autoDetectLanguage) {
                    Text("Auto-detect spoken language for translation")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .toggleStyle(.switch)
                
                // Auto-response toggle
                Toggle(isOn: $autoResponseMode) {
                    Text("Auto-response mode (tap to speak, auto-translate)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .toggleStyle(.switch)
                
                // Conversation direction buttons
                HStack(spacing: 12) {
                    Button {
                        conversationDirection = .youToThem
                    } label: {
                        Text("You → Them")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(
                                conversationDirection == .youToThem
                                ? Color.blue.opacity(0.2)
                                : Color.clear
                            )
                            .cornerRadius(10)
                    }
                    
                    Button {
                        conversationDirection = .themToYou
                    } label: {
                        Text("Them → You")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .foregroundColor(.primary)
                            .background(
                                conversationDirection == .themToYou
                                ? Color.blue.opacity(0.2)
                                : Color.clear
                            )
                            .cornerRadius(10)
                    }
                }
                
                // Direction summary banner
                HStack {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .foregroundColor(.white)
                    Text(directionSummary)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.85))
                .cornerRadius(12)
                
                // Heard phrase
                VStack(alignment: .leading, spacing: 6) {
                    let heardLabel: String = {
                        if autoDetectLanguage {
                            return conversationDirection == .youToThem
                            ? "Heard phrase (You, auto-detect)"
                            : "Heard phrase (Them, auto-detect)"
                        } else {
                            return conversationDirection == .youToThem
                            ? "Heard phrase (\(youLanguage.displayName))"
                            : "Heard phrase (\(theyLanguage.displayName))"
                        }
                    }()
                    
                    Text(heardLabel)
                        .font(.headline)
                    
                    Text(heardPhrase.isEmpty ? "…" : heardPhrase)
                        .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    // NEW: Paste from clipboard and translate
                    HStack {
                        Button {
                            pasteIntoHeardAndTranslate()
                        } label: {
                            Label("Paste & translate", systemImage: "doc.on.clipboard")
                        }
                        .font(.caption2)
                        
                        Spacer()
                    }
                }
                
                // Translation
                VStack(alignment: .leading, spacing: 6) {
                    let translationLabel: String = {
                        switch conversationDirection {
                        case .youToThem:
                            return "Translation (\(theyLanguage.displayName))"
                        case .themToYou:
                            return "Translation (\(youLanguage.displayName))"
                        }
                    }()
                    
                    Text(translationLabel)
                        .font(.headline)
                    
                    Text(translatedText.isEmpty ? "…" : translatedText)
                        .textSelection(.enabled) // allow copy
                        .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    // NEW: Copy translation to clipboard
                    HStack {
                        Button {
                            copyTranslatedToPasteboard()
                        } label: {
                            Label("Copy translation", systemImage: "doc.on.doc")
                        }
                        .font(.caption2)
                        
                        Spacer()
                    }
                }
                
                // MARK: - Play + Mic row (side-by-side)
                VStack(spacing: 12) {

                    ZStack {
                        HStack(alignment: .top) {

                            // LEFT: Play button
                            VStack(spacing: 6) {
                                Button {
                                    ttsManager.speak(
                                        translatedText,
                                        languageCode: playTTSCode,
                                        useSpeaker: false
                                    )
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 80, height: 80)
                                            .shadow(radius: 4)

                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 28, weight: .bold))
                                    }
                                }

                                Text("Play \(playLanguageName)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 100)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 10)

                            // RIGHT: Mic button
                            VStack(spacing: 6) {
                                if autoResponseMode {
                                    // TAP mode (auto-response)
                                    ZStack {
                                        Circle()
                                            .fill(isListening ? Color.red : Color.blue)
                                            .frame(width: 80, height: 80)
                                            .shadow(radius: isListening ? 8 : 4)
                                            .scaleEffect(isListening ? 1.05 : 1.0)

                                        Image(systemName: "mic.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30, weight: .bold))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        handleAutoResponseTap()
                                    }

                                } else {
                                    // HOLD mode (walkie-talkie)
                                    ZStack {
                                        Circle()
                                            .fill(isListening ? Color.red : Color.blue)
                                            .frame(width: 80, height: 80)
                                            .shadow(radius: isListening ? 8 : 4)
                                            .scaleEffect(isListening ? 1.05 : 1.0)

                                        Image(systemName: isListening ? "mic.fill" : "mic")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30, weight: .bold))
                                    }
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { _ in
                                                if !isPressingMic {
                                                    isPressingMic = true
                                                    showHoldToSpeakTip()
                                                    startListeningOnce()
                                                }
                                            }
                                            .onEnded { _ in
                                                if isPressingMic {
                                                    isPressingMic = false
                                                    stopListeningOnce(
                                                        autoSpeak: true,
                                                        restartAfterTranslation: false
                                                    )
                                                }
                                            }
                                    )
                                }

                                Text(micLabel)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 130)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.leading, 10)
                        }

                        // ✅ Tip overlay (appears between the two buttons, no layout shift)
                        if !autoResponseMode {
                            Text("Hold → speak → release")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(Color(.systemBackground).opacity(0.85))
                                .clipShape(Capsule())
                                .opacity(showHoldTip ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: showHoldTip)
                                .allowsHitTesting(false)
                                .offset(y: 12)
                        }
                    }
                }
                
                // MARK: - Listen & Repeat Practice Entry
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        activeSheet = .listenRepeat
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "ear.badge.waveform")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Listen & Repeat practice")
                                    .font(.headline)
                                Text("Hear a phrase, repeat it, and get a score on your pronunciation.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.top, 24)
                
                // QUICK PHRASES SECTION
                VStack(alignment: .leading, spacing: 8) {
                    
                    Button {
                        withAnimation {
                            showPhrases.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Quick phrases")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showPhrases ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if showPhrases {
                        // Category picker
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(PhraseCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        // Travel subcategory – dropdown menu
                        if selectedCategory == .travel {
                            Picker("Travel type", selection: $selectedTravelSubcategory) {
                                ForEach(TravelSubcategory.allCases) { sub in
                                    Text(sub.rawValue).tag(sub)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Text("Tap a phrase to hear it in \(theyLanguage.displayName).")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Decide which phrase list to use
                        let currentPhrases: [String] = {
                            if selectedCategory == .travel {
                                return travelPhrasesBySubcategory[selectedTravelSubcategory] ?? []
                            } else {
                                return phrasesByCategory[selectedCategory] ?? []
                            }
                        }()
                        
                        // Wheel picker of phrases
                        if !currentPhrases.isEmpty {
                            Picker("Phrase", selection: $selectedPhraseIndex) {
                                ForEach(currentPhrases.indices, id: \.self) { index in
                                    Text(currentPhrases[index]).tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxHeight: 140)
                        }
                        
                        // Play phrase button (uses version 1 translator)
                        Button {
                            playQuickPhrase(phrases: currentPhrases)
                        } label: {
                            Label("Play phrase in \(theyLanguage.displayName)",
                                  systemImage: "play.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.top, 32)
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        // Live transcript -> heardPhrase (and auto-stop in auto-response mode)
        .onChange(of: speechRecognizer.transcript) { _, newValue in
            if isListening {
                let trimmed = newValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                heardPhrase = trimmed
                
                // In auto-response mode, auto-stop after ~1.5s of no new text
                if autoResponseMode {
                    silenceWorkItem?.cancel()
                    
                    let workItem = DispatchWorkItem {
                        if isListening && autoResponseMode {
                            stopListeningOnce(
                                autoSpeak: true,
                                restartAfterTranslation: false
                            )
                        }
                    }
                    silenceWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
                }
            }
        }
        // Re-translate if the target ("They hear") language changes
        .onChange(of: theyLanguage) { _, _ in
            handleLanguageChangeReTranslation()
        }
        .alert("Daily limit reached",
               isPresented: $showDailyLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You’ve reached today’s free limit of \(DailyLimitManager.shared.maxPerDayLimit()) translations on this device. Please try again tomorrow.")
        }
        // Unified sheet for practice view
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .listenRepeat:
                ListenRepeatPracticeView(
                    practiceLanguage: theyLanguage,
                    translator: translator,
                    presetEnglishPhrases: v1SelectedPhrasesForPractice
                )
            }
        }
    }
    
    // MARK: - Core listening helpers
    
    
    private func showHoldToSpeakTip() {
        holdTipWorkItem?.cancel()
        showHoldTip = true

        let work = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.25)) {
                showHoldTip = false
            }
        }
        holdTipWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: work)
    }
    
    
    private var v1SelectedPhrasesForPractice: [String] {
        switch selectedCategory {
        case .travel:
            return travelPhrasesBySubcategory[selectedTravelSubcategory] ?? []
        default:
            return phrasesByCategory[selectedCategory] ?? []
        }
    }
    
    
    /// Single-shot listening used by walkie-talkie mode and auto-response.
    private func startListeningOnce() {
        silenceWorkItem?.cancel()
        
        statusMessage  = "Listening…"
        isListening    = true
        heardPhrase    = ""
        translatedText = ""
        
        let localeIdentifier: String = {
            switch conversationDirection {
            case .youToThem:
                return youLanguage.localeIdentifier
            case .themToYou:
                return theyLanguage.localeIdentifier
            }
        }()
        
        speechRecognizer.startTranscribing(localeIdentifier: localeIdentifier)
    }
    
    /// Stop listening, then translate. Optionally auto-speak and/or restart listening.
    private func stopListeningOnce(autoSpeak: Bool, restartAfterTranslation: Bool) {
        guard isListening else { return }
        
        isListening   = false
        statusMessage = "Translating…"
        
        silenceWorkItem?.cancel()
        speechRecognizer.stopTranscribing()
        
        let recognizerText = speechRecognizer.transcript
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let finalTextRaw = recognizerText.isEmpty
        ? heardPhrase
        : recognizerText
        
        let transcript = finalTextRaw
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        heardPhrase = transcript
        
        guard !transcript.isEmpty else {
            translatedText = ""
            statusMessage  = "No speech detected"
            return
        }
        
        performTranslation(
            for: transcript,
            autoSpeak: autoSpeak,
            restartAfterTranslation: restartAfterTranslation
        )
    }
    
    /// Shared translation logic, with auto-detect support.
    private func performTranslation(for transcript: String,
                                    autoSpeak: Bool,
                                    restartAfterTranslation: Bool) {
        // 🔐 Daily limit check
        let allowed = DailyLimitManager.shared.consumeOneIfAvailable()
        guard allowed else {
            showDailyLimitAlert = true
            statusMessage = "Daily limit reached"
            return
        }
        
        let fromCode: String? = {
            if autoDetectLanguage {
                return nil // let Azure detect
            } else {
                switch conversationDirection {
                case .youToThem:
                    return youLanguage.azureCode
                case .themToYou:
                    return theyLanguage.azureCode
                }
            }
        }()
        
        let toCode: String = {
            switch conversationDirection {
            case .youToThem:
                return theyLanguage.azureCode
            case .themToYou:
                return youLanguage.azureCode
            }
        }()
        
        let ttsCode: String = {
            switch conversationDirection {
            case .youToThem:
                return theyLanguage.ttsCode
            case .themToYou:
                return youLanguage.ttsCode
            }
        }()
        
        translator.translate(
            text: transcript,
            from: fromCode,
            to:   toCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    self.translatedText = translated
                    self.statusMessage  = "Translated."
                    
                    if autoSpeak {
                        self.ttsManager.speak(
                            translated,
                            languageCode: ttsCode,
                            useSpeaker: false
                        )
                    }
                    
                    if restartAfterTranslation,
                       self.isAutoSessionActive,
                       self.autoResponseMode {
                        self.startListeningOnce()
                    }
                    
                case .failure(let error):
                    self.translatedText = "Error: \(error.localizedDescription)"
                    self.statusMessage  = "Error."
                }
            }
        }
    }
    
    /// Re-translate current heard phrase whenever "They hear" changes (no auto speak).
    private func handleLanguageChangeReTranslation() {
        let transcript = heardPhrase
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !transcript.isEmpty else { return }
        
        statusMessage = "Translating…"
        
        let fromCode: String? = {
            if autoDetectLanguage {
                return nil
            } else {
                switch conversationDirection {
                case .youToThem:
                    return youLanguage.azureCode
                case .themToYou:
                    return theyLanguage.azureCode
                }
            }
        }()
        
        let toCode: String = {
            switch conversationDirection {
            case .youToThem:
                return theyLanguage.azureCode
            case .themToYou:
                return youLanguage.azureCode
            }
        }()
        
        translator.translate(
            text: transcript,
            from: fromCode,
            to:   toCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    self.translatedText = translated
                    self.statusMessage  = "Translated."
                case .failure(let error):
                    self.translatedText = "Error: \(error.localizedDescription)"
                    self.statusMessage  = "Error."
                }
            }
        }
    }
    
    private func swapLanguages() {
        let temp = theyLanguage
        theyLanguage = youLanguage
        youLanguage  = temp
    }
    
    // MARK: - Auto-response tap behavior (session)
    
    private func handleAutoResponseTap() {
        // If already listening, let the silence timer decide when to stop.
        if isListening {
            return
        }
        
        isAutoSessionActive = true
        startListeningOnce()
    }
    
    // MARK: - Clipboard helpers
    
    /// Take whatever text is currently on the clipboard, drop it into
    /// the Heard phrase box, and run the usual translation + TTS.
    private func pasteIntoHeardAndTranslate() {
        guard let pastedRaw = UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !pastedRaw.isEmpty
        else {
            return
        }
        
        heardPhrase    = pastedRaw
        translatedText = ""
        statusMessage  = "Translating…"
        
        performTranslation(
            for: pastedRaw,
            autoSpeak: true,
            restartAfterTranslation: false
        )
    }
    
    /// Copy the current translated text to the clipboard.
    private func copyTranslatedToPasteboard() {
        let trimmed = translatedText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        UIPasteboard.general.string = trimmed
        statusMessage = "Copied translation"
    }
    
    // MARK: - Quick phrase playback
    
    private func playQuickPhrase(phrases: [String]) {
        guard !phrases.isEmpty else { return }
        
        // 🔐 Daily limit check
        let allowed = DailyLimitManager.shared.consumeOneIfAvailable()
        guard allowed else {
            showDailyLimitAlert = true
            statusMessage = "Daily limit reached"
            return
        }
        
        let englishPhrase = phrases[selectedPhraseIndex]
        
        heardPhrase    = englishPhrase
        statusMessage  = "Translating phrase…"
        translatedText = ""
        
        translator.translate(
            text: englishPhrase,
            from: ConversationLanguage.english.azureCode,
            to:   theyLanguage.azureCode
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let translated):
                    self.translatedText = translated
                    self.statusMessage  = "Phrase translated."
                    
                    self.ttsManager.speak(
                        translated,
                        languageCode: self.theyLanguage.ttsCode,
                        useSpeaker: false
                    )
                    
                case .failure(let error):
                    self.translatedText = "Error: \(error.localizedDescription)"
                    self.statusMessage  = "Error."
                }
            }
        }
    }
}
