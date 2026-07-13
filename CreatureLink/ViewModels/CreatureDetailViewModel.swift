//
//  CreatureDetailViewModel.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/17/26.
//

import Foundation
import SwiftUI

@MainActor
final class CreatureDetailViewModel: ObservableObject {
    
    let session: CreatureSession
    @Published var shouldShowErrorAlert: Bool = false
    
    @Published var selectedCommand: CreatureCommand = .feed
    @Published private(set) var isSendingCommand: Bool = false
    @Published var shouldShowCommandErrorAlert: Bool = false
    @Published private(set) var commandErrorMessage: String = ""
    
    private let connectionService: CreatureConnectionService
    private var connectionTask: Task<Void, Never>?
    
    private let commandService: CreatureCommandService
    
    private let liveUpdateService: CreatureLiveUpdateService
    
    private var liveUpdateTask: Task<Void, Never>?
    
    private var commandTask: Task<Void, Never>?
    
    private var isCommandInFlight: Bool {
        isSendingCommand
    }
    
    init(
        session: CreatureSession,
        connectionService: CreatureConnectionService,
        commandService: CreatureCommandService,
        liveUpdateService: CreatureLiveUpdateService
    ) {
        self.session = session
        self.connectionService = connectionService
        self.commandService = commandService
        self.liveUpdateService = liveUpdateService
        
        if session.creature.signalCategory == "Unknown" {
            session.connectionState = .unavailable
        }
    }
    
    deinit {
        connectionTask?.cancel()
        commandTask?.cancel()
        liveUpdateTask?.cancel()
    }
    
    func connectTapped() {
        guard connectionTask == nil else { return }
        
        switch session.connectionState {
        case .connected, .connecting, .reconnecting, .unavailable:
            return
            
        case .disconnected, .failed:
            break
        }
        
        session.connectionState = .connecting
        
        connectionTask = Task {
            do {
                try await connectionService.connect(to: session.creature)
                
                if Task.isCancelled {
                    connectionTask = nil
                    return
                }
                
                session.creature.isConnected = true
                session.connectionState = .connected
                
                startLiveUpdates()
                
            } catch {
                if Task.isCancelled {
                    connectionTask = nil
                    return
                }
                
                session.creature.isConnected = false
                session.connectionState = .failed(error.localizedDescription)
                shouldShowErrorAlert = true
            }
            
            connectionTask = nil
        }
    }
    
    func sendSelectedCommandTapped() {
        guard case .connected = session.connectionState else { return }
        guard commandTask == nil else { return }

        let command = selectedCommand
        isSendingCommand = true

        commandTask = Task {
            defer {
                isSendingCommand = false
                commandTask = nil
            }

            do {
                let updatedCreature = try await commandService.send(
                    command: command,
                    to: session.creature
                )

                if Task.isCancelled {
                    return
                }

                applyCreatureUpdate(updatedCreature)
            } catch {
                if Task.isCancelled {
                    return
                }

                commandErrorMessage = error.localizedDescription
                shouldShowCommandErrorAlert = true
            }
        }
    }
    
    func disconnectTapped() {
        guard connectionTask == nil else { return }
        guard commandTask == nil else { return }
        guard case .connected = session.connectionState else { return }

        connectionTask = Task {
            await connectionService.disconnect(from: session.creature)

            if Task.isCancelled {
                connectionTask = nil
                return
            }

            session.creature.isConnected = false
            stopLiveUpdates()
            session.connectionState = .disconnected
            connectionTask = nil
        }
    }
    
    func dismissErrorAlert() {
        shouldShowErrorAlert = false
        
        if session.creature.signalCategory == "Unknown" {
            session.connectionState = .unavailable
            return
        }
        
        if case .failed = session.connectionState {
            session.connectionState = .disconnected
        }
    }
    
    private func startLiveUpdates() {
        stopLiveUpdates()
        
        liveUpdateTask = Task {
            let stream = liveUpdateService.liveUpdates(for: session.creature)
            
            for await event in stream {
                if Task.isCancelled {
                    return
                }
                
                handleLiveUpdate(event)
            }
        }
    }

    private func stopLiveUpdates() {
        liveUpdateTask?.cancel()
        liveUpdateTask = nil
    }

    private func handleLiveUpdate(_ event: CreatureLiveUpdateEvent) {
        switch event {
        case .updated(let updatedCreature):
            
            // Prevent overwriting command result mid-flight
            if isCommandInFlight {
                return
            }
            
            applyCreatureUpdate(updatedCreature)
            
        case .disconnected(let message):
            session.creature.isConnected = false
            session.connectionState = .failed(message)
            shouldShowErrorAlert = true
            stopLiveUpdates()
        }
    }
    
    private func applyCreatureUpdate(_ updatedCreature: Creature) {
        session.creature = updatedCreature
    }
}
