//
//  ScriptedCreatureConnectionService.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/17/26.
//

import Foundation
@testable import CreatureLink

actor ScriptedCreatureConnectionService: CreatureConnectionService {
    enum Behavior: Sendable {
        case connectSucceeds
        case connectFails(Error)
    }
    
    private let behavior: Behavior
    private let connectDelayNanoseconds: UInt64
    private let disconnectDelayNanoseconds: UInt64
    
    private(set) var connectCallCount: Int = 0
    private(set) var disconnectCallCount: Int = 0
    
    init(
        behavior: Behavior,
        connectDelayNanoseconds: UInt64 = 1_000_000,
        disconnectDelayNanoseconds: UInt64 = 1_000_000
    ) {
        self.behavior = behavior
        self.connectDelayNanoseconds = connectDelayNanoseconds
        self.disconnectDelayNanoseconds = disconnectDelayNanoseconds
    }
    
    func connect(to creature: Creature) async throws {
        connectCallCount += 1
        try await Task.sleep(nanoseconds: connectDelayNanoseconds)
        
        switch behavior {
        case .connectSucceeds:
            return
        case .connectFails(let error):
            throw error
        }
    }
    
    func disconnect(from creature: Creature) async {
        disconnectCallCount += 1
        try? await Task.sleep(nanoseconds: disconnectDelayNanoseconds)
    }
}
