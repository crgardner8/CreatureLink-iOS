//
//  CreatureLiveUpdateService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/28/26.
//

import Foundation

protocol CreatureLiveUpdateService {
    func liveUpdates(for creature: Creature) -> AsyncStream<CreatureLiveUpdateEvent>
}
