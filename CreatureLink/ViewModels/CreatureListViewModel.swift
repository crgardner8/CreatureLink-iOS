//
//  CreatureListViewModel.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation
import SwiftUI

@MainActor
final class CreatureListViewModel: ObservableObject {
    
    @Published private(set) var creatureSessions: [CreatureSession] = []
    @Published var selectedSession: CreatureSession?
    
    @Published private(set) var discoveryState: DiscoveryState = .idle
    @Published private(set) var statusMessage: String = "Ready to scan"
    
    private let scannerService: CreatureScannerService
    private var scanTask: Task<Void, Never>?
    
    init(scannerService: CreatureScannerService) {
        self.scannerService = scannerService
    }
    
    func startScanning() {
        guard scanTask == nil else { return }
        
        discoveryState = .scanning
        statusMessage = "Scanning for nearby creatures..."
        creatureSessions.removeAll()
        
        scanTask = Task {
            let stream = scannerService.scan()
            
            for await event in stream {
                handle(event)
                
                if Task.isCancelled {
                    break
                }
            }
            
            if case .scanning = discoveryState {
                discoveryState = .stopped
                statusMessage = "Scan completed"
            }
            
            scanTask = nil
        }
    }
    
    func stopScanning() {
        guard scanTask != nil else { return }
        
        discoveryState = .stopping
        statusMessage = "Stopping scan..."
        
        scanTask?.cancel()
        scanTask = nil
        
        discoveryState = .stopped
        statusMessage = "Scan stopped by user"
    }
    
    func selectSession(_ session: CreatureSession) {
        stopScanning()
        selectedSession = session
    }
    
    private func handle(_ event: ScanEvent) {
        switch event {
        case .discovered(let creature):
            upsert(creature)
            statusMessage = "Discovered \(creature.name)"
            
        case .updated(let creature):
            upsert(creature)
            statusMessage = "Updated \(creature.name)"
            
        case .lost(let id):
            creatureSessions.removeAll { $0.id == id }
            statusMessage = "A creature moved out of range"
            
        case .scanFinished:
            discoveryState = .stopped
            statusMessage = "Scan completed"
            
        case .scanFailed(let message):
            discoveryState = .failed(message)
            statusMessage = message
        }
    }
    
    private func upsert(_ creature: Creature) {
        guard shouldDisplay(creature) else {
            creatureSessions.removeAll { $0.id == creature.id }
            return
        }
        
        if let index = creatureSessions.firstIndex(where: { $0.id == creature.id }) {
            creatureSessions[index].creature = creature
        } else {
            creatureSessions.append(
                CreatureSession(creature: creature)
            )
        }

        creatureSessions.sort {
            $0.creature.signalStrength > $1.creature.signalStrength
        }
    }
    
    private func shouldDisplay(_ creature: Creature) -> Bool {
    
        guard creature.signalCategory != "Unknown" else {
            return false
        }
        
        return creature.signalStrength > AppConstants.Discovery.minimumSignalStregth
    }
}
