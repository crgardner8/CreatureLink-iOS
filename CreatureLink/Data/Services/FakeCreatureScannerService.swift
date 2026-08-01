//
//  FakeCreatureScannerService.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import Foundation

final class FakeCreatureScannerService: CreatureScannerService {
    
    private let configuration: ScannerConfiguration
    private let randomizer: RandomNumberProviding
    
    init(
        configuration: ScannerConfiguration = .default,
        randomizer: RandomNumberProviding = SystemRandomNumberProvider()
    ) {
        self.configuration = configuration
        self.randomizer = randomizer
    }
    
    func scan() -> AsyncStream<ScanEvent> {
        AsyncStream { continuation in
            let configurationSnapshot = configuration
            let randomizerSnapshot = randomizer
            
            let task = Task {
                var activeCreatures: [Creature] = []
                let possibleCreatures = Self.sampleCreatures()
                
                for _ in 1...configurationSnapshot.scanIterations {
                    let delay = UInt64(
                        randomizerSnapshot.int(
                            in: Int(configurationSnapshot.minimumDelayNanoseconds)...Int(configurationSnapshot.maximumDelayNanoseconds)
                        )
                    )
                    
                    try? await Task.sleep(nanoseconds: delay)
                    
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    
                    let roll = randomizerSnapshot.int(in: 1...100)
                    
                    switch roll {
                    case 1...55:
                        if let candidate = randomizerSnapshot.element(from: possibleCreatures) {
                            if let existingIndex = activeCreatures.firstIndex(where: { $0.id == candidate.id }) {
                                var updated = activeCreatures[existingIndex]
                                updated.signalStrength = randomizerSnapshot.int(in: 20...100)
                                updated.mood = randomizerSnapshot.element(from: Mood.allCases) ?? updated.mood
                                activeCreatures[existingIndex] = updated
                                continuation.yield(.updated(updated))
                            } else {
                                var discovered = candidate
                                discovered.signalStrength = randomizerSnapshot.int(in: 30...100)
                                activeCreatures.append(discovered)
                                continuation.yield(.discovered(discovered))
                            }
                        }
                        
                    case 56...75:
                        if !activeCreatures.isEmpty {
                            let index = randomizerSnapshot.int(in: 0..<activeCreatures.count)
                            let lostCreature = activeCreatures.remove(at: index)
                            continuation.yield(.lost(lostCreature.id))
                        }
                        
                    case 76...(100 - configurationSnapshot.scanFailureRatePercent):
                        continue
                        
                    default:
                        continuation.yield(.scanFailed("Intermittent scan interruption"))
                        continuation.finish()
                        return
                    }
                }
                
                continuation.yield(.scanFinished)
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

private extension FakeCreatureScannerService {
    static func sampleCreatures() -> [Creature] {
        [
            Creature(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                name: "EmberFox",
                type: .fire,
                energy: 82,
                mood: .excited,
                signalStrength: 0,
                isConnected: false
            ),
            Creature(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                name: "AquaTurtle",
                type: .water,
                energy: 61,
                mood: .sleepy,
                signalStrength: 0,
                isConnected: false
            ),
            Creature(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
                name: "VoltBunny",
                type: .electric,
                energy: 90,
                mood: .happy,
                signalStrength: 0,
                isConnected: false
            ),
            Creature(
                id: UUID(uuidString: "44444444-4444-4444-4444-444444444444") ?? UUID(),
                name: "TerraCub",
                type: .earth,
                energy: 74,
                mood: .bored,
                signalStrength: 0,
                isConnected: false
            )
        ]
    }
}
