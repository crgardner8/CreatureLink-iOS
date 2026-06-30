//
//  CreatureScannerService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation

protocol CreatureScannerService {
    func scan() -> AsyncStream<ScanEvent>
}

enum ScanEvent: Equatable {
    case discovered(Creature)
    case updated(Creature)
    case lost(UUID)
    case scanFinished
    case scanFailed(String)
}
