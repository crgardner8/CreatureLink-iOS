//
//  CreatureListViewModelTests.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/16/26.
//

import XCTest
@testable import CreatureLink

@MainActor
final class CreatureListViewModelTests: XCTestCase {
    
    func test_startScanning_setsStateToScanningImmediately() {
        let scannerService = ScriptedCreatureScannerService(events: [])
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        
        XCTAssertEqual(
            testCreatureListViewModel.discoveryState,
            .scanning
        )
        XCTAssertEqual(
            testCreatureListViewModel.statusMessage,
            "Scanning for nearby creatures..."
        )
        XCTAssertTrue(
            testCreatureListViewModel.creatureSessions.isEmpty
        )
    }
    
    func test_discoveredCreature_isAddedToList() async {
        let creature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "EmberFox",
            signalStrength: 80
        )
        
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .discovered(creature),
                .scanFinished
            ]
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureListViewModel.creatureSessions.count,
            1
        )
        XCTAssertEqual(
            testCreatureListViewModel.creatureSessions.first?.creature.name,
            "EmberFox"
        )
        XCTAssertEqual(
            testCreatureListViewModel.discoveryState,
            .stopped
        )
    }
    
    func test_updatedCreature_replacesExistingCreature_insteadOfDuplicating() async {
        let originalCreature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "EmberFox",
            signalStrength: 50
        )
        
        let updatedCreature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "EmberFox",
            signalStrength: 90,
            mood: .happy
        )
        
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .discovered(originalCreature),
                .updated(updatedCreature),
                .scanFinished
            ]
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureListViewModel.creatureSessions.count,
            1
        )
        XCTAssertEqual(
            testCreatureListViewModel.creatureSessions.first?
                .creature.signalStrength,
            90
        )
        XCTAssertEqual(
            testCreatureListViewModel.creatureSessions.first?
                .creature.mood,
            .happy
        )
    }
    
    func test_lostCreature_removesCreatureFromList() async {
        let creature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "EmberFox",
            signalStrength: 80
        )
        
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .discovered(creature),
                .lost(creature.id),
                .scanFinished
            ]
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        await waitForProcessing()
        
        XCTAssertTrue(
            testCreatureListViewModel.creatureSessions.isEmpty
        )
        XCTAssertEqual(
            testCreatureListViewModel.discoveryState,
            .stopped
        )
    }
    
    func test_scanFailed_setsFailedStateAndMessage() async {
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .scanFailed("Scanner unavailable")
            ]
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureListViewModel.discoveryState,
            .failed("Scanner unavailable")
        )
        XCTAssertEqual(
            testCreatureListViewModel.statusMessage,
            "Scanner unavailable"
        )
    }
    
    func test_stopScanning_setsStoppedState() async {
        let creature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "EmberFox",
            signalStrength: 80
        )
        
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .discovered(creature),
                .updated(creature),
                .scanFinished
            ],
            delayNanoseconds: 100_000_000
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        testCreatureListViewModel.stopScanning()
        
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureListViewModel.discoveryState,
            .stopped
        )
        XCTAssertEqual(
            testCreatureListViewModel.statusMessage,
            "Scan stopped by user"
        )
    }
    
    func test_creatureSessions_areSortedBySignalStrengthDescending() async {
        let lowSignalCreature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "Low",
            signalStrength: 30
        )
        
        let highSignalCreature = makeCreature(
            id: "22222222-2222-2222-2222-222222222222",
            name: "High",
            signalStrength: 90
        )
        
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .discovered(lowSignalCreature),
                .discovered(highSignalCreature),
                .scanFinished
            ]
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureListViewModel.creatureSessions.map {
                $0.creature.name
            },
            ["High", "Low"]
        )
    }
    
    func test_stopScanning_setsStoppingThenStoppedStateAndMessage() async {
        let creature = makeCreature(
            id: "11111111-1111-1111-1111-111111111111",
            name: "EmberFox",
            signalStrength: 80
        )
        
        let scannerService = ScriptedCreatureScannerService(
            events: [
                .discovered(creature),
                .scanFinished
            ],
            delayNanoseconds: 200_000_000
        )
        
        let testCreatureListViewModel = CreatureListViewModel(
            scannerService: scannerService
        )
        
        testCreatureListViewModel.startScanning()
        testCreatureListViewModel.stopScanning()
        
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureListViewModel.discoveryState,
            .stopped
        )
        XCTAssertEqual(
            testCreatureListViewModel.statusMessage,
            "Scan stopped by user"
        )
    }
}

private extension CreatureListViewModelTests {
    
    func makeCreature(
        id: String,
        name: String,
        signalStrength: Int,
        mood: Mood = .excited
    ) -> Creature {
        Creature(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            type: .fire,
            energy: 80,
            mood: mood,
            signalStrength: signalStrength,
            isConnected: false
        )
    }
    
    func waitForProcessing() async {
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
}
