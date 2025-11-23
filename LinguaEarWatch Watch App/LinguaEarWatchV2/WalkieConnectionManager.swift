//
//  WalkieConnectionManager.swift
//  LinguaEarWatchV2
//

import Foundation
import Combine

/// Central state holder for walkie mode.
/// Right now this is all stubbed logic so we can design the UI safely.
final class WalkieConnectionManager: ObservableObject {

    @Published var peers: [WalkiePeer] = [.sample]
    @Published var selectedPeer: WalkiePeer? = .sample
    @Published var state: WalkieState = .idle
    @Published var lastMessage: String? = nil

    // MARK: - Public API (stubs for now)

    func connectIfNeeded() {
        guard state == .idle else { return }
        state = .connecting

        // Fake "connect" delay for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.state = .ready
        }
    }

    func startTalking() {
        connectIfNeeded()
        state = .sending
        lastMessage = "You are talking… (stub)"
    }

    func stopTalking() {
        // When user lets go, go back to ready
        state = .ready
    }

    func simulateIncoming() {
        // Handy later for testing UI: pretend someone else is talking
        state = .receiving
        lastMessage = "They are talking… (stub)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            if case .receiving = self.state {
                self.state = .ready
            }
        }
    }

    func reset() {
        state = .idle
        lastMessage = nil
    }
}
