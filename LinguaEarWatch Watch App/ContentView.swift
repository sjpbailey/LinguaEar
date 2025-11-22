//
//  ContentView.swift
//  LinguaEarWatch Watch App
//
//  Simple Watch translator:
//  - You dictate or type a phrase
//  - It sends text to Azure via TranslatorService
//  - It auto-plays the result using TextToSpeechManager
//

import SwiftUI

struct ContentView: View {

    // Shared logic from the iPhone app
    @StateObject private var translator = TranslatorService()
    @StateObject private var tts        = TextToSpeechManager()

    // UI state
    @State private var inputText: String      = ""
    @State private var translatedText: String = ""
    @State private var isTranslating: Bool    = false

    // Default: You = English, They = Spanish
    @State private var fromLang: ConversationLanguage = .english
    @State private var toLang:   ConversationLanguage = .spanish

    // Daily limit alert
    @State private var showDailyLimitAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {

                    // Title
                    Text("LinguaEar")
                        .font(.headline)

                    // Big, easy-to-read language summary
                    Text("\(fromLang.displayName) → \(toLang.displayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    // MARK: - "Tap to speak" pill (main action)

                    Text("Tap to speak")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    TextField("Tap to speak…", text: $inputText)
                        .lineLimit(1)
                        .onSubmit {
                            translateOnWatch()
                        }
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .background(Color.accentColor.opacity(0.25))
                        .clipShape(Capsule())

                    // Translate button (same behavior as onSubmit)
                    Button {
                        translateOnWatch()
                    } label: {
                        if isTranslating {
                            HStack {
                                ProgressView()
                                Text("Translating…")
                            }
                        } else {
                            Text("Translate")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating)

                    // Result
                    VStack(alignment: .leading, spacing: 4) {
                        Text("They hear")
                            .font(.caption2)
                            .foregroundColor(.gray)

                        Text(translatedText.isEmpty ? "…" : translatedText)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)

                    // MARK: - Languages section moved to bottom as big tappable rows

                    Divider()
                        .padding(.vertical, 4)

                    Text("Languages")
                        .font(.caption2)
                        .foregroundColor(.gray)

                    // "You speak" row
                    NavigationLink {
                        LanguagePickerView(
                            selection: $fromLang,
                            title: "You speak"
                        )
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("You speak")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(fromLang.displayName)
                                    .font(.body)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }

                    // "They hear" row
                    NavigationLink {
                        LanguagePickerView(
                            selection: $toLang,
                            title: "They hear"
                        )
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("They hear")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(toLang.displayName)
                                    .font(.body)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }

                    // Swap button under language rows
                    Button {
                        swapLanguages()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Swap")
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)

                    Spacer(minLength: 4)
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            // Daily limit alert
            .alert("Daily limit reached",
                   isPresented: $showDailyLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You’ve reached today’s free limit of \(DailyLimitManager.shared.maxPerDayLimit()) translations on this device. Please try again tomorrow.")
            }
        }
    }

    // MARK: - Actions

    private func swapLanguages() {
        let temp = fromLang
        fromLang = toLang
        toLang   = temp
    }

    private func translateOnWatch() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 🔐 Daily limit check
        let allowed = DailyLimitManager.shared.consumeOneIfAvailable()
        guard allowed else {
            showDailyLimitAlert = true
            return
        }

        isTranslating = true

        let fromCode = fromLang.azureCode
        let toCode   = toLang.azureCode

        translator.translate(
            text: trimmed,
            from: fromCode,
            to:   toCode
        ) { result in
            DispatchQueue.main.async {
                self.isTranslating = false
                switch result {
                case .success(let translated):
                    self.translatedText = translated

                    // 🔊 Auto-speak the result
                    self.playOnWatch()

                    // ✅ Clear input so it's ready for the next person
                    self.inputText = ""

                case .failure(let error):
                    self.translatedText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func playOnWatch() {
        let trimmed = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        tts.speak(
            trimmed,
            languageCode: toLang.ttsCode,
            useSpeaker: true   // watch just uses its speaker
        )
    }
}
struct LanguagePickerView: View {
    @Binding var selection: ConversationLanguage
    let title: String

    var body: some View {
        List {
            ForEach(ConversationLanguage.allCases) { lang in
                Button {
                    selection = lang
                } label: {
                    HStack {
                        Text(lang.displayName)
                        Spacer()
                        if lang == selection {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
#Preview {
    ContentView()
}
