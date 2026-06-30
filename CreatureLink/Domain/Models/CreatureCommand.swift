//
//  CreatureCommand.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/27/26.
//

import Foundation

enum CreatureCommand: String, CaseIterable, Identifiable {
    case feed
    case play
    case rest
    
    var id: String { rawValue }
    
    var displayTitle: String {
        switch self {
        case .feed:
            return "Feed"
        case .play:
            return "Play"
        case .rest:
            return "Rest"
        }
    }
}
