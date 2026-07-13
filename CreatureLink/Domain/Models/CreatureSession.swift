//
//  CreatureSessionViewModel.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 5/7/26.
//

import Foundation
import SwiftUI

@MainActor
final class CreatureSession: ObservableObject, Identifiable {
    
    let id: UUID
    
    @Published var creature: Creature
    @Published var connectionState: ConnectionState = .disconnected
    
    init(creature: Creature) {
        self.id = creature.id
        self.creature = creature
        
        if creature.signalCategory == "Unknown" {
            connectionState = .unavailable
        }
    }
}

extension CreatureSession {
    static func == (lhs: CreatureSession, rhs: CreatureSession) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
