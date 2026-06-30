//
//  DiscoveryState.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation

enum DiscoveryState: Equatable {
    case idle
    case scanning
    case stopping
    case stopped
    case unavailable
    case failed(String)
}
