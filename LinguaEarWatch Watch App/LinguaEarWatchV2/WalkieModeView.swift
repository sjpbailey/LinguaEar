//
//  WalkieModeView.swift
//  LinguaEarWatchV2
//

import SwiftUI

struct WalkieModeView: View {

    @StateObject private var manager = WalkieConnectionManager()
    private let audio = WalkieAudioCapture()

    var body: some View {
        VStack(spacing: 8) {
            // Peer / channel info
            Text(manager.selectedPeer?.displayName ?? "No channel")
                .font(.headline)

            statusLine
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            // Big push-to-talk button
            talkButton

            if let last = manager.lastMessage {
                Text(last)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Spacer(minLength: 4)

            HStack {
                Button("More…") {
                    // later: push help / settings
                }
                .font(.caption2)

                Spacer()
            }
        }
        .padding()
        .onAppear {
            manager.connectIfNeeded()
        }
    }

    private var statusLine: some View {
        let text: String
        switch manager.state {
        case .idle:       text = "Idle"
        case .connecting: text = "Connecting…"
        case .ready:      text = "Ready to talk"
        case .sending:    text = "You’re talking"
        case .receiving:  text = "Listening…"
        case .error(let message): text = "Error: \(message)"
        }
        return Text(text)
    }

    private var talkButton: some View {
        // One button that acts like push-to-talk:
        // onPress -> startTalking, onRelease -> stopTalking
        Button {
            // tap toggles for now; later we can use gestures for press & hold
            if manager.state == .sending {
                audio.stop()
                manager.stopTalking()
            } else {
                audio.start()
                manager.startTalking()
            }
        } label: {
            Text(manager.state == .sending ? "Release to stop" : "Hold to talk")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(manager.state == .sending ? Color.red : Color.blue)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WalkieModeView()
}
