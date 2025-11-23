//
//  WalkieState.swift
//  LinguaEarWatchV2
//

import Foundation

/// High-level connection / audio state for the walkie mode.
enum WalkieState: Equatable {
    case idle                  // Not connected, not talking
    case connecting            // Trying to connect
    case ready                 // Connected, ready to talk
    case sending               // User is holding to talk
    case receiving             // Peer is talking
    case error(String)         // Human-readable error
}
