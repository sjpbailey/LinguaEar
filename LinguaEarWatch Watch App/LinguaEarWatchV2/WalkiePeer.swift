//
//  WalkiePeer.swift
//  LinguaEarWatchV2
//

import Foundation

/// Represents another device / person in walkie mode.
/// For now this is just a stub; later we can wire it to real discovery.
struct WalkiePeer: Identifiable, Hashable {
    let id: UUID
    var displayName: String

    init(id: UUID = UUID(), displayName: String) {
        self.id = id
        self.displayName = displayName
    }

    static let sample = WalkiePeer(displayName: "Salon Front Desk")
}
