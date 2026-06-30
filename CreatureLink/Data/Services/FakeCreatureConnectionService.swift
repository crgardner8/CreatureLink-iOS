//
//  FakeCreatureConnectionService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/17/26.
//

import Foundation

enum ConnectionError: LocalizedError {
    case timeout
    case unstableSignal
    case deviceRejectedHandshake
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Connection timed out."
        case .unstableSignal:
            return "Signal became unstable during connection."
        case .deviceRejectedHandshake:
            return "The creature rejected the connection handshake."
        }
    }
}

final class FakeCreatureConnectionService: CreatureConnectionService {
    func connect(to creature: Creature) async throws {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        let roll = Int.random(in: 1...100)
        
        switch roll {
        case 1...70:
            return
        case 71...85:
            throw ConnectionError.timeout
        case 86...95:
            throw ConnectionError.unstableSignal
        default:
            throw ConnectionError.deviceRejectedHandshake
        }
    }
    
    func disconnect(from creature: Creature) async {
        try? await Task.sleep(nanoseconds: 400_000_000)
    }
}
