//
//  CreatureConnectionService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/17/26.
//

import Foundation

protocol CreatureConnectionService: Sendable {
    func connect(to creature: Creature) async throws
    func disconnect(from creature: Creature) async
}
