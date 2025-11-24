//
//  WalkieTalkieModeView.swift
//  LinguaEarWatch Watch App
//
//  V2 - Concept UI only (no networking yet)
//

import SwiftUI

struct WalkieTalkieModeView: View {
    
    // Just local UI state for now
    @State private var youLanguage: String  = "English"
    @State private var themLanguage: String = "Spanish"
    
    @State private var lastHeard: String       = ""
    @State private var lastTranslation: String = ""
    
    @State private var isListening: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                
                // Title
                Text("LinguaEar V2")
                    .font(.headline)
                
                // Direction summary
                Text("\(youLanguage) → \(themLanguage)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Divider()
                
                // "Heard" area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Heard")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(lastHeard.isEmpty ? "…" : lastHeard)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(6)
                        .background(Color.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // "Translated" area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Translated")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(lastTranslation.isEmpty ? "…" : lastTranslation)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(6)
                        .background(Color.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // Big “walkie-talkie” button
                Button {
                    // For now, just fake some text so we can see the UI update
                    if isListening {
                        // Stop “listening” and fake a translation
                        isListening = false
                        lastHeard = "Hola, ¿cómo estás?"
                        lastTranslation = "Hi, how are you?"
                    } else {
                        // Start “listening”
                        isListening = true
                        lastHeard = ""
                        lastTranslation = ""
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isListening ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                            .shadow(radius: isListening ? 6 : 3)
                        
                        Image(systemName: isListening ? "mic.fill" : "mic")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text(isListening ? "Listening… tap to stop" : "Tap to speak")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Divider()
                
                // Simple fake language pickers (for now just buttons)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Languages (UI only for now)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Button(youLanguage) {
                            // Cycle through a few just to prove it works
                            youLanguage = nextLanguage(after: youLanguage)
                        }
                        Spacer()
                        Text("→")
                        Spacer()
                        Button(themLanguage) {
                            themLanguage = nextLanguage(after: themLanguage)
                        }
                    }
                    .font(.footnote)
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
    
    // Simple local “cycle languages” helper
    private func nextLanguage(after current: String) -> String {
        let options = ["English", "Spanish", "French", "Portuguese", "Turkish"]
        guard let index = options.firstIndex(of: current) else { return options[0] }
        let next = index + 1
        return next < options.count ? options[next] : options[0]
    }
}

#Preview {
    WalkieTalkieModeView()
}
