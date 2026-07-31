//
//  CreatureDetailCommandTests.swift
//  CreatureLinkTests
//
//  Created by Clifton Gardner on 4/27/26.
//

import XCTest
@testable import CreatureLink

@MainActor
final class CreatureDetailCommandTests: XCTestCase {
    
    func test_sendSelectedCommand_doesNothing_whenDisconnected() async {
        let creature = makeCreature(isConnected: false)
        let commandService = ScriptedCreatureCommandService(
            behavior: .succeeds(creature)
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: creature,
            commandService: commandService
        )
        
        testCreatureDetailViewModel.sendSelectedCommandTapped()
        await waitForProcessing()
        
        let sendCallCount = await commandService.sendCallCount
        XCTAssertEqual(sendCallCount, 0)
    }
    
    func test_sendSelectedCommand_sendsSelectedCommand_whenConnected() async {
        let connectedCreature = makeCreature(isConnected: true)
        let updatedCreature = makeCreature(
            energy: 100,
            mood: .happy,
            isConnected: true
        )
        
        let commandService = ScriptedCreatureCommandService(
            behavior: .succeeds(updatedCreature)
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: connectedCreature,
            commandService: commandService
        )
        
        await connect(testCreatureDetailViewModel)
        
        testCreatureDetailViewModel.selectedCommand = .feed
        testCreatureDetailViewModel.sendSelectedCommandTapped()
        await waitForProcessing()
        
        let sendCallCount = await commandService.sendCallCount
        let lastCommand = await commandService.lastCommand
        XCTAssertEqual(sendCallCount, 1)
        XCTAssertEqual(lastCommand, .feed)
    }
    
    func test_sendSelectedCommand_updatesCreature_whenCommandSucceeds() async {
        let connectedCreature = makeCreature(
            energy: 60,
            mood: .bored,
            isConnected: true
        )
        
        let updatedCreature = makeCreature(
            energy: 70,
            mood: .happy,
            isConnected: true
        )
        
        let commandService = ScriptedCreatureCommandService(
            behavior: .succeeds(updatedCreature)
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: connectedCreature,
            commandService: commandService
        )
        
        await connect(testCreatureDetailViewModel)
        
        testCreatureDetailViewModel.selectedCommand = .feed
        testCreatureDetailViewModel.sendSelectedCommandTapped()
        await waitForProcessing()
        
        XCTAssertEqual(testCreatureDetailViewModel.session.creature.energy, 70)
        XCTAssertEqual(testCreatureDetailViewModel.session.creature.mood, .happy)
        XCTAssertFalse(testCreatureDetailViewModel.isSendingCommand)
        XCTAssertFalse(testCreatureDetailViewModel.shouldShowCommandErrorAlert)
    }
    
    func test_sendSelectedCommand_showsErrorAlert_whenCommandFails() async {
        let connectedCreature = makeCreature(isConnected: true)

        let commandService = ScriptedCreatureCommandService(
            behavior: .fails(TestCommandError.commandRejected)
        )

        let testCreatureDetailViewModel = makeViewModel(
            creature: connectedCreature,
            commandService: commandService
        )

        await connect(testCreatureDetailViewModel)

        testCreatureDetailViewModel.selectedCommand = .play
        testCreatureDetailViewModel.sendSelectedCommandTapped()

        await waitUntil {
            !testCreatureDetailViewModel.isSendingCommand
        }

        let sendCallCount = await commandService.sendCallCount
        let lastCommand = await commandService.lastCommand
        XCTAssertEqual(sendCallCount, 1)
        XCTAssertEqual(lastCommand, .play)
        XCTAssertTrue(testCreatureDetailViewModel.shouldShowCommandErrorAlert)
        XCTAssertEqual(
            testCreatureDetailViewModel.commandErrorMessage,
            TestCommandError.commandRejected.localizedDescription
        )
        XCTAssertFalse(testCreatureDetailViewModel.isSendingCommand)
    }
    
    func test_sendSelectedCommand_doesNotStartSecondCommand_whenCommandAlreadyInFlight() async {
        let connectedCreature = makeCreature(isConnected: true)
        let updatedCreature = makeCreature(energy: 100, isConnected: true)
        
        let commandService = ScriptedCreatureCommandService(
            behavior: .succeeds(updatedCreature),
            delayNanoseconds: 200_000_000
        )
        
        let testCreatureDetailViewModel = makeViewModel(
            creature: connectedCreature,
            commandService: commandService
        )
        
        await connect(testCreatureDetailViewModel)
        
        testCreatureDetailViewModel.sendSelectedCommandTapped()
        testCreatureDetailViewModel.sendSelectedCommandTapped()
        
        await waitForProcessing()
        
        let sendCallCount = await commandService.sendCallCount
        XCTAssertEqual(sendCallCount, 1)
    }
}

private extension CreatureDetailCommandTests {
    
    func makeViewModel(
        creature: Creature,
        commandService: CreatureCommandService,
        liveUpdateService: CreatureLiveUpdateService = NoOpCreatureLiveUpdateService()
    ) -> CreatureDetailViewModel {
        CreatureDetailViewModel(
            session: CreatureSession(creature: creature),
            connectionService: ScriptedCreatureConnectionService(
                behavior: .connectSucceeds
            ),
            commandService: commandService,
            liveUpdateService: liveUpdateService
        )
    }
    
    func makeCreature(
        energy: Int = 80,
        mood: Mood = .excited,
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
    
    func connect(_ viewModel: CreatureDetailViewModel) async {
        viewModel.connectTapped()
        await waitForProcessing()
        XCTAssertEqual(viewModel.session.connectionState, .connected)
    }
    
    func waitForProcessing() async {
        try? await Task.sleep(nanoseconds: 75_000_000)
    }
    
    func waitUntil(
        timeoutNanoseconds: UInt64 = 1_000_000_000,
        condition: @escaping @MainActor () -> Bool
    ) async {
        let pollingIntervalNanoseconds: UInt64 = 10_000_000
        var elapsedNanoseconds: UInt64 = 0

        while !condition() && elapsedNanoseconds < timeoutNanoseconds {
            try? await Task.sleep(
                nanoseconds: pollingIntervalNanoseconds
            )

            elapsedNanoseconds += pollingIntervalNanoseconds
        }

        XCTAssertTrue(
            condition(),
            "Timed out waiting for asynchronous condition."
        )
    }
}

private enum TestCommandError: LocalizedError {
    case commandRejected
    
    var errorDescription: String? {
        switch self {
        case .commandRejected:
            return "Test command rejected"
        }
    }
}
