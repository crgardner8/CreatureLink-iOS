//
//  FakeCreatureCommandService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/27/26.
//

import Foundation

enum CreatureCommandError: LocalizedError {
    case notConnected
    case commandTimedOut
    case rejected
    
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "The creature is not connected."
        case .commandTimedOut:
            return "The command timed out."
        case .rejected:
            return "The creature rejected the command."
        }
    }
}

final class FakeCreatureCommandService: CreatureCommandService, Sendable {
    
    func send(
        command: CreatureCommand,
        to creature: Creature
    ) async throws -> Creature {
        try await Task.sleep(nanoseconds: 700_000_000)
        
        guard creature.isConnected else {
            throw CreatureCommandError.notConnected
        }
        
        let roll = Int.random(in: 1...100)
        
        if roll > 85 {
            throw CreatureCommandError.commandTimedOut
        }
        
        var updatedCreature = creature
        
        switch command {
        case .feed:
            updatedCreature.energy = min(creature.energy + 10, 100)
            updatedCreature.mood = .happy
            
        case .play:
            updatedCreature.energy = max(creature.energy - 8, 0)
            updatedCreature.mood = .excited
            
        case .rest:
            updatedCreature.energy = min(creature.energy + 15, 100)
            updatedCreature.mood = .sleepy
        }
        
        return updatedCreature
    }
}
