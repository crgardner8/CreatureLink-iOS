//
//  CreatureDetailViewModelTests.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/17/26.
//

import XCTest
@testable import CreatureLink

@MainActor
final class CreatureDetailViewModelTests: XCTestCase {
    
    func test_initialState_isDisconnected_forValidSignalCategory() {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(behavior: .connectSucceeds)
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .disconnected)
        XCTAssertFalse(testCreatureDetailViewModel.session.creature.isConnected)
        XCTAssertFalse(testCreatureDetailViewModel.shouldShowErrorAlert)
    }
    
    func test_initialState_isUnavailable_forUnknownSignalCategory() {
        let creature = makeCreature(signalStrength: 999)
        let connectionService = ScriptedCreatureConnectionService(behavior: .connectSucceeds)
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .unavailable)
    }
    
    func test_connectTapped_setsConnectedState_whenConnectionSucceeds() async {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(behavior: .connectSucceeds)
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .connected)
        XCTAssertTrue(testCreatureDetailViewModel.session.creature.isConnected)
        let connectCallCount = await connectionService.connectCallCount
        XCTAssertEqual(connectCallCount, 1)
        XCTAssertFalse(testCreatureDetailViewModel.shouldShowErrorAlert)
    }
    
    func test_connectTapped_setsFailedStateAndShowsAlert_whenConnectionFails() async {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(
            behavior: .connectFails(TestConnectionError.handshakeFailed)
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(
            testCreatureDetailViewModel.session.connectionState,
            .failed(TestConnectionError.handshakeFailed.localizedDescription)
        )
        XCTAssertFalse(testCreatureDetailViewModel.session.creature.isConnected)
        XCTAssertTrue(testCreatureDetailViewModel.shouldShowErrorAlert)
        let connectCallCount = await connectionService.connectCallCount
        XCTAssertEqual(connectCallCount, 1)
    }
    
    func test_disconnectTapped_setsDisconnectedState_whenCurrentlyConnected() async {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(behavior: .connectSucceeds)
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .connected)
        
        testCreatureDetailViewModel.disconnectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .disconnected)
        XCTAssertFalse(testCreatureDetailViewModel.session.creature.isConnected)
        let disconnectCallCount = await connectionService.disconnectCallCount
        XCTAssertEqual(disconnectCallCount, 1)
    }
    
    func test_disconnectTapped_doesNothing_whenNotConnected() async {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(behavior: .connectSucceeds)
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        testCreatureDetailViewModel.disconnectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .disconnected)
        let disconnectCallCount = await connectionService.disconnectCallCount
        XCTAssertEqual(disconnectCallCount, 0)
    }
    
    func test_connectTapped_doesNothing_whenStateIsUnavailable() async {
        let creature = makeCreature(signalStrength: -1)
        let connectionService = ScriptedCreatureConnectionService(behavior: .connectSucceeds)
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .unavailable)
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .unavailable)
        let connectCallCount = await connectionService.connectCallCount
        XCTAssertEqual(connectCallCount, 0)
    }
    
    func test_dismissErrorAlert_resetsFailedStateToDisconnected_forValidSignalCategory() async {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(
            behavior: .connectFails(TestConnectionError.timeout)
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        testCreatureDetailViewModel.connectTapped()
        await waitForProcessing()
        
        XCTAssertTrue(testCreatureDetailViewModel.shouldShowErrorAlert)
        
        testCreatureDetailViewModel.dismissErrorAlert()
        
        XCTAssertFalse(testCreatureDetailViewModel.shouldShowErrorAlert)
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .disconnected)
    }
    
    func test_dismissErrorAlert_resetsToUnavailable_forUnknownSignalCategory() async {
        let creature = makeCreature(signalStrength: 999)
        let connectionService = ScriptedCreatureConnectionService(
            behavior: .connectFails(TestConnectionError.timeout)
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .unavailable)
        
        testCreatureDetailViewModel.shouldShowErrorAlert = true
        testCreatureDetailViewModel.dismissErrorAlert()
        
        XCTAssertFalse(testCreatureDetailViewModel.shouldShowErrorAlert)
        XCTAssertEqual(testCreatureDetailViewModel.session.connectionState, .unavailable)
    }
    
    func test_connectTapped_doesNotStartSecondConnection_whenTaskAlreadyInFlight() async {
        let creature = makeCreature(signalStrength: 80)
        let connectionService = ScriptedCreatureConnectionService(
            behavior: .connectSucceeds,
            connectDelayNanoseconds: 200_000_000
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            connectionService: connectionService
        )
        
        testCreatureDetailViewModel.connectTapped()
        testCreatureDetailViewModel.connectTapped()
        
        await waitForProcessing()
        
        let connectCallCount = await connectionService.connectCallCount
        XCTAssertEqual(connectCallCount, 1)
    }
}

private extension CreatureDetailViewModelTests {
    func makeCreature(
        signalStrength: Int,
        isConnected: Bool = false
    ) -> Creature {
        Creature(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            name: "VoltBunny",
            type: .electric,
            energy: 90,
            mood: .happy,
            signalStrength: signalStrength,
            isConnected: isConnected
        )
    }
    
    func makeViewModel(
        creature: Creature,
        connectionService: CreatureConnectionService,
        commandService: CreatureCommandService? = nil,
        liveUpdateService: CreatureLiveUpdateService = NoOpCreatureLiveUpdateService()
    ) -> CreatureDetailViewModel {
        CreatureDetailViewModel(
            session: CreatureSession(creature: creature),
            connectionService: connectionService,
            commandService: commandService ?? ScriptedCreatureCommandService(
                behavior: .succeeds(creature)
            ),
            liveUpdateService: liveUpdateService
        )
    }
    
    func waitForProcessing() async {
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
}

private enum TestConnectionError: LocalizedError {
    case timeout
    case handshakeFailed
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Test timeout"
        case .handshakeFailed:
            return "Test handshake failed"
        }
    }
}
