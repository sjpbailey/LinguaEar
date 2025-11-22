//
//  WelcomeView.swift
//  LinguaEar
//
//  Front-door welcome + help screen.
//  No translation logic here, just explanations and a button to start.
//

import SwiftUI

struct WelcomeView: View {
    
    // When we wire this into the app entry, we’ll wrap this in a NavigationStack
    // and use this bool with a NavigationLink, but for now it just drives the preview.
    @State private var isShowingTranslator: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Hero / Title
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "ear.badge.waveform")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LinguaEar")
                                    .font(.system(size: 36, weight: .bold))
                                
                                Text("Listen. Understand. Reply.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text("A conversation-first translator for real life — salons, travel, construction sites, and everyday moments where people don’t share the same language.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)
                    
                    // MARK: - Quick Start
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick start")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Choose who speaks and who hears at the top (You / Them).", systemImage: "person.2.fill")
                            Label("Pick languages from the menus — for example: You = English, They = Spanish.", systemImage: "globe")
                            Label("Tap a mic mode, speak, and LinguaEar will translate and speak for you.", systemImage: "mic.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    // MARK: - Modes (Expandable)
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 10) {
                            
                            // Hold to Speak
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hold to Speak (Walkie-Talkie)")
                                    .font(.subheadline.bold())
                                Text("Press and hold the mic button while you talk. When you let go, LinguaEar translates what you said and speaks it in the other language.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            // Auto-Response
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Auto-Response Mode")
                                    .font(.subheadline.bold())
                                Text("Turn on Auto-Response when you want hands-free phrases. Tap once, speak a sentence, pause, and LinguaEar will translate and speak it automatically.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            // Paste & Translate
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Paste & Translate")
                                    .font(.subheadline.bold())
                                Text("You can paste a block of text into the Heard box to translate and hear it spoken. Great for emails, messages, or written instructions.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            // Quick Phrases
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Quick Phrases")
                                    .font(.subheadline.bold())
                                Text("Use the Quick Phrases section for ready-made lines in Basic, Travel, Salon, and Conversation. Pick a phrase and LinguaEar will translate and speak it in the selected language.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                            Text("Modes & Features")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: - Real-World Examples (Expandable)
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("At the hair salon")
                                    .font(.subheadline.bold())
                                Text("""
                                • You speak English, your stylist speaks Spanish.
                                • Set: You = English, They = Spanish.
                                • Use Auto-Response or Hold-to-Speak to say what you want (“Just a little shorter, please”).
                                • LinguaEar plays it in Spanish for them.
                                """)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Taxi / Travel")
                                    .font(.subheadline.bold())
                                Text("""
                                • Choose Travel → Taxi in Quick Phrases.
                                • Scroll through ready-to-use phrases like “Please take me here” or “How much is the fare?”
                                • Tap Play to speak them out in the driver’s language.
                                """)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("On a job site")
                                    .font(.subheadline.bold())
                                Text("""
                                • Background noise? Use Hold-to-Speak for short, clear sentences.
                                • Let LinguaEar speak the translation loud and clear in the language your crew understands.
                                """)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reading a long message")
                                    .font(.subheadline.bold())
                                Text("""
                                • Copy a message or paragraph.
                                • Paste it into the Heard box.
                                • Let LinguaEar translate and read it out in the language you choose.
                                """)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        HStack {
                            Image(systemName: "person.2.wave.2.fill")
                                .foregroundColor(.green)
                            Text("How to use it in real life")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: - Tips (Expandable)
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Speak in short, clear sentences.")
                            Text("• Pause briefly after each thought to let LinguaEar translate.")
                            Text("• Check that your “You” and “They” languages match the people talking.")
                            Text("• If things get weird, try turning Auto-Response off and use simple Hold-to-Speak.")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                            Text("Tips for best results")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: - Watch Version (Just Info)
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("""
                            The Apple Watch version is designed for quick, simple exchanges:
                            • Choose languages on your wrist.
                            • Dictate a short phrase.
                            • Play the translation for the person in front of you.
                            
                            We’re keeping it lightweight so you can use it without pulling out your phone.
                            """)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    } label: {
                        HStack {
                            Image(systemName: "applewatch")
                                .foregroundColor(.purple)
                            Text("About the Watch app")
                                .font(.headline)
                        }
                    }
                    
                    // MARK: - Start Button
                    VStack(spacing: 12) {
                        Button {
                            isShowingTranslator = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("Start translating", systemImage: "arrow.right.circle.fill")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(radius: 4)
                        }
                        
                        Text("You can come back here later for help by restarting the app.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationDestination(isPresented: $isShowingTranslator) {
                // This is your existing main view:
                ContentView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
