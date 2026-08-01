//
//  ScannerConfiguration.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation

struct ScannerConfiguration: Equatable, Sendable {
    let scanIterations: Int
    let minimumDelayNanoseconds: UInt64
    let maximumDelayNanoseconds: UInt64
    let scanFailureRatePercent: Int
    
    static let `default` = ScannerConfiguration(
        scanIterations: 12,
        minimumDelayNanoseconds: 700_000_000,
        maximumDelayNanoseconds: 1_500_000_000,
        scanFailureRatePercent: 3
    )
}
