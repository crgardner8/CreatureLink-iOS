//
//  ConnectionState.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/17/26.
//

import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case unavailable
    case failed(String)
}
