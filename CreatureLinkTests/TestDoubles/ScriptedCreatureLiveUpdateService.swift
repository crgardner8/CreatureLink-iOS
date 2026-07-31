//
//  ScriptedCreatureLiveUpdateService.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/29/26.
//

import Foundation
@testable import CreatureLink

final class ScriptedCreatureLiveUpdateService: CreatureLiveUpdateService {
    private let events: [CreatureLiveUpdateEvent]
    private let delayNanoseconds: UInt64
    
    init(
        events: [CreatureLiveUpdateEvent],
        delayNanoseconds: UInt64 = 1_000_000
    ) {
        self.events = events
        self.delayNanoseconds = delayNanoseconds
    }
    
    func liveUpdates(for creature: Creature) -> AsyncStream<CreatureLiveUpdateEvent> {
        AsyncStream { continuation in
            let eventsSnapshot = events
            let delaySnapshot = delayNanoseconds
            
            let task = Task {
                for event in eventsSnapshot {
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    
                    try? await Task.sleep(nanoseconds: delaySnapshot)
                    
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    
                    continuation.yield(event)
                }
                
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
