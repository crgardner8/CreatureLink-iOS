//
//  ScriptedCreatureCommandService.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/27/26.
//

import Foundation
@testable import CreatureLink

final class ScriptedCreatureCommandService: CreatureCommandService {
    enum Behavior {
        case succeeds(Creature)
        case fails(Error)
    }
    
    private let behavior: Behavior
    private let delayNanoseconds: UInt64
    
    private(set) var sendCallCount = 0
    private(set) var lastCommand: CreatureCommand?
    
    init(
        behavior: Behavior,
        delayNanoseconds: UInt64 = 1_000_000
    ) {
        self.behavior = behavior
        self.delayNanoseconds = delayNanoseconds
    }
    
    func send(
        command: CreatureCommand,
        to creature: Creature
    ) async throws -> Creature {
        sendCallCount += 1
        lastCommand = command
        
        try await Task.sleep(nanoseconds: delayNanoseconds)
        
        switch behavior {
        case .succeeds(let updatedCreature):
            return updatedCreature
        case .fails(let error):
            throw error
        }
    }
}
