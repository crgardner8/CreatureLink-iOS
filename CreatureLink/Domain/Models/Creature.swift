//
//  Creature.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation

struct Creature: Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: CreatureType
    var energy: Int
    var mood: Mood
    var signalStrength: Int
    var isConnected: Bool
    
    var signalCategory: String {
        switch signalStrength {
            case 0...29: return "Weak"
            case 30...69: return "Fair"
            case 70...100: return "Strong"
            default: return "Unknown"
        }
    }
}

enum CreatureType: String, CaseIterable {
    case fire
    case water
    case electric
    case earth
}

enum Mood: String, CaseIterable {
    case happy
    case sleepy
    case excited
    case bored
}

