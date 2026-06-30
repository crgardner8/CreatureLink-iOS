//
//  CreatureDetailView.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/17/26.
//

import SwiftUI

struct CreatureDetailView: View {
    @StateObject private var viewModel: CreatureDetailViewModel
    @ObservedObject private var session: CreatureSession
    
    init(viewModel: CreatureDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _session = ObservedObject(wrappedValue: viewModel.session)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            statsSection
            connectionSection
            commandSection
            Spacer()
        }
        .padding()
        .navigationTitle(session.creature.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Connection Error", isPresented: $viewModel.shouldShowErrorAlert) {
            Button("OK") {
                viewModel.dismissErrorAlert()
            }
        } message: {
            if case .failed(let message) = session.connectionState {
                Text(message)
            } else {
                Text("Unknown connection error.")
            }
        }
        .alert("Command Error", isPresented: $viewModel.shouldShowCommandErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.commandErrorMessage)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(session.creature.name)
                .font(.largeTitle)
                .bold()
            
            Text(session.creature.type.rawValue.capitalized)
                .font(.title3)
                .foregroundColor(.secondary)
            
            ConnectionStatusBadge(state: session.connectionState)
            
            Text(statusSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Creature Stats")
                .font(.headline)
            
            HStack {
                Text("Mood")
                Spacer()
                Text(session.creature.mood.rawValue.capitalized)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Energy")
                Spacer()
                Text("\(session.creature.energy)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Signal")
                Spacer()
                Text("\(session.creature.signalStrength)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Signal Category")
                Spacer()
                Text(session.creature.signalCategory)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var connectionSection: some View {
        VStack(spacing: 16) {
            if case .connecting = session.connectionState {
                ProgressView("Connecting...")
                    .frame(maxWidth: .infinity)
            }
            
            if case .reconnecting = session.connectionState {
                ProgressView("Reconnecting...")
                    .frame(maxWidth: .infinity)
            }
            
            if case .unavailable = session.connectionState {
                Text("Connection unavailable due to current signal conditions.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                Button("Connect") {
                    viewModel.connectTapped()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isConnectDisabled)
                
                Button("Disconnect") {
                    viewModel.disconnectTapped()
                }
                .buttonStyle(.bordered)
                .disabled(!isConnected)
            }
        }
    }
    
    private var commandSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Creature Commands")
                .font(.headline)
            
            CommandPickerView(
                selectedCommand: $viewModel.selectedCommand
            )
            
            Button {
                viewModel.sendSelectedCommandTapped()
            } label: {
                if viewModel.isSendingCommand {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send \(viewModel.selectedCommand.displayTitle)")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSendCommand)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var isConnectDisabled: Bool {
        switch session.connectionState {
        case .connecting, .connected, .reconnecting, .unavailable:
            return true
        case .disconnected, .failed:
            return false
        }
    }
    
    private var isConnected: Bool {
        if case .connected = session.connectionState {
            return true
        }
        return false
    }
    
    private var statusSubtitle: String {
        switch session.connectionState {
        case .disconnected:
            return "Ready to connect"
        case .connecting:
            return "Establishing handshake..."
        case .connected:
            return "Creature link active"
        case .reconnecting:
            return "Attempting to recover connection..."
        case .unavailable:
            return "Connection cannot be started right now"
        case .failed:
            return "Connection needs retry"
        }
    }
    
    private var canSendCommand: Bool {
        guard case .connected = session.connectionState else {
            return false
        }
        
        return !viewModel.isSendingCommand
    }
}

struct CreatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreatureDetailView(
                viewModel: CreatureDetailViewModel(
                    session: CreatureSession(
                        creature: Creature(
                            id: UUID(),
                            name: "VoltBunny",
                            type: .electric,
                            energy: 90,
                            mood: .happy,
                            signalStrength: 84,
                            isConnected: false
                        )
                    ),
                    connectionService: FakeCreatureConnectionService(),
                    commandService: FakeCreatureCommandService(),
                    liveUpdateService: FakeCreatureLiveUpdateService()
                )
            )
        }
    }
}
