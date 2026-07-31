//
//  CreatureCommandService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/27/26.
//

import Foundation

protocol CreatureCommandService: Sendable {
    func send(
        command: CreatureCommand,
        to creature: Creature
    ) async throws -> Creature
}
