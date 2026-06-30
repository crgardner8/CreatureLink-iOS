//
//  CreatureLiveUpdateEvent.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/28/26.
//

import Foundation

enum CreatureLiveUpdateEvent: Equatable {
    case updated(Creature)
    case disconnected(String)
}
