//
//  CreatureDetailLiveUpdateTests.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/29/26.
//

import XCTest
@testable import CreatureLink

@MainActor
final class CreatureDetailLiveUpdateTests: XCTestCase {
    
    func test_liveUpdate_updatesCreature_whenConnected() async {
        let initialCreature = makeCreature(
            energy: 80,
            mood: .happy,
            signalStrength: 80,
            isConnected: false
        )
        
        let updatedCreature = makeCreature(
            energy: 72,
            mood: .sleepy,
            signalStrength: 65,
            isConnected: true
        )
        
        let liveUpdateService = ScriptedCreatureLiveUpdateService(
            events: [.updated(updatedCreature)]
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: initialCreature,
            liveUpdateService: liveUpdateService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.connectionState, .connected)
        
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.creature.energy, 72)
        XCTAssertEqual(testCreatureDetailViewModel.creature.mood, .sleepy)
        XCTAssertEqual(testCreatureDetailViewModel.creature.signalStrength, 65)
    }
    
    func test_liveUpdateDisconnected_setsFailedStateAndShowsAlert() async {
        let creature = makeCreature(isConnected: false)
        
        let liveUpdateService = ScriptedCreatureLiveUpdateService(
            events: [.disconnected("Live connection dropped.")]
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            liveUpdateService: liveUpdateService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureDetailViewModel.connectionState,
            .failed("Live connection dropped.")
        )
        XCTAssertFalse(testCreatureDetailViewModel.creature.isConnected)
        XCTAssertTrue(testCreatureDetailViewModel.shouldShowErrorAlert)
    }
    
    func test_liveUpdateDoesNotOverwriteCreature_whenCommandIsInFlight() async {
        let initialCreature = makeCreature(
            energy: 80,
            mood: .happy,
            signalStrength: 80,
            isConnected: false
        )
        
        let liveUpdatedCreature = makeCreature(
            energy: 20,
            mood: .bored,
            signalStrength: 40,
            isConnected: true
        )
        
        let commandUpdatedCreature = makeCreature(
            energy: 95,
            mood: .excited,
            signalStrength: 80,
            isConnected: true
        )
        
        let liveUpdateService = ScriptedCreatureLiveUpdateService(
            events: [.updated(liveUpdatedCreature)],
            delayNanoseconds: 50_000_000
        )
        
        let commandService = ScriptedCreatureCommandService(
            behavior: .succeeds(commandUpdatedCreature),
            delayNanoseconds: 150_000_000
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: initialCreature,
            commandService: commandService,
            liveUpdateService: liveUpdateService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        testCreatureDetailViewModel.selectedCommand = .play
        testCreatureDetailViewModel.sendSelectedCommandTapped()
        
        await waitForLongerProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.creature.energy, 95)
        XCTAssertEqual(testCreatureDetailViewModel.creature.mood, .excited)
        XCTAssertEqual(commandService.sendCallCount, 1)
    }
}

private extension CreatureDetailLiveUpdateTests {
    
    func makeViewModel(
        creature: Creature,
        commandService: CreatureCommandService? = nil,
        liveUpdateService: CreatureLiveUpdateService
    ) -> CreatureDetailViewModel {
        CreatureDetailViewModel(
            creature: creature,
            connectionService: ScriptedCreatureConnectionService(
                behavior: .connectSucceeds
            ),
            commandService: commandService ?? ScriptedCreatureCommandService(
                behavior: .succeeds(creature)
            ),
            liveUpdateService: liveUpdateService
        )
    }
    
    func makeCreature(
        energy: Int = 80,
        mood: Mood = .happy,
        signalStrength: Int = 80,
        isConnected: Bool
    ) -> Creature {
        Creature(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            name: "VoltBunny",
            type: .electric,
            energy: energy,
            mood: mood,
            signalStrength: signalStrength,
            isConnected: isConnected
        )
    }
    
    func waitForProcessing() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
    
    func waitForLongerProcessing() async {
        try? await Task.sleep(nanoseconds: 250_000_000)
    }
}
