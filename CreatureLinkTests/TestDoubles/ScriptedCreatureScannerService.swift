//
//  ScriptedCreatureScannerService.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation
@testable import CreatureLink

final class ScriptedCreatureScannerService: CreatureScannerService {
    private let events: [ScanEvent]
    private let delayNanoseconds: UInt64
    
    init(events: [ScanEvent], delayNanoseconds: UInt64 = 1_000_000) {
        self.events = events
        self.delayNanoseconds = delayNanoseconds
    }
    
    func scan() -> AsyncStream<ScanEvent> {
        AsyncStream { continuation in
            let task = Task {
                for event in events {
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    
                    try? await Task.sleep(nanoseconds: delayNanoseconds)
                    
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    
                    continuation.yield(event)
                }
                
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
