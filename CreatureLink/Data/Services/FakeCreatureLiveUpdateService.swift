//
//  FakeCreatureLiveUpdateService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/28/26.
//

import Foundation

final class FakeCreatureLiveUpdateService: CreatureLiveUpdateService {
    
    func liveUpdates(for creature: Creature) -> AsyncStream<CreatureLiveUpdateEvent> {
        AsyncStream { continuation in
            let task = Task {
                var currentCreature = creature
                
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    
                    let roll = Int.random(in: 1...100)
                    
                    if roll > 95 {
                        continuation.yield(.disconnected("Live connection dropped."))
                        continuation.finish()
                        return
                    }
                    
                    currentCreature.energy = max(
                        0,
                        min(100, currentCreature.energy + Int.random(in: -5...3))
                    )
                    
                    currentCreature.signalStrength = max(
                        0,
                        min(100, currentCreature.signalStrength + Int.random(in: -8...8))
                    )
                    
                    if roll <= 25 {
                        currentCreature.mood = Mood.allCases.randomElement() ?? currentCreature.mood
                    }
                    
                    continuation.yield(.updated(currentCreature))
                }
                
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
