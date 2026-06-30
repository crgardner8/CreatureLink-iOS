//
//  NoOpCreatureLiveUpdateService.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/29/26.
//

import Foundation
@testable import CreatureLink

final class NoOpCreatureLiveUpdateService: CreatureLiveUpdateService {
    func liveUpdates(for creature: Creature) -> AsyncStream<CreatureLiveUpdateEvent> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
