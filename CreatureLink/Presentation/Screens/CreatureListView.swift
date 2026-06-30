//
//  CreatureListView.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import SwiftUI

struct CreatureListView: View {
    @StateObject private var viewModel: CreatureListViewModel
    
    init(viewModel: CreatureListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                headerView
                
                if viewModel.creatureSessions.isEmpty {
                    emptyStateView
                } else {
                    List(viewModel.creatureSessions) { creatureSession in
                        NavigationLink {
                            CreatureDetailView(
                                viewModel: CreatureDetailViewModel(
                                    session: creatureSession,
                                    connectionService: FakeCreatureConnectionService(),
                                    commandService: FakeCreatureCommandService(),
                                    liveUpdateService: FakeCreatureLiveUpdateService()
                                )
                            )
                            .onAppear {
                                viewModel.stopScanning()
                            }
                        } label: {
                            CreatureRowView(creature: creatureSession.creature)
                        }
                    }
                    .listStyle(.plain)
                }
                
                actionBar
            }
            .padding()
            .navigationTitle("CreatureLink")
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Nearby Creatures")
                .font(.title2)
                .bold()
            
            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundColor(statusColor)
            
            Text("\(viewModel.creatureSessions.count) discovered")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("No creatures discovered yet")
                .font(.headline)
            Text("Start a scan to search for nearby digital companions.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("Start Scan") {
                viewModel.startScanning()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isScanning)
            
            Button("Stop") {
                viewModel.stopScanning()
            }
            .buttonStyle(.bordered)
            .disabled(!isScanning)
        }
    }
    
    private var isScanning: Bool {
        switch viewModel.discoveryState {
        case .scanning, .stopping:
            return true
        case .idle, .stopped, .unavailable, .failed:
            return false
        }
    }
    
    private var statusColor: Color {
        switch viewModel.discoveryState {
        case .idle:
            return .secondary
        case .scanning:
            return .blue
        case .stopping:
            return .orange
        case .stopped:
            return .secondary
        case .unavailable:
            return .red
        case .failed:
            return .red
        }
    }
}

struct CreatureListView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureListView(
            viewModel: CreatureListViewModel(
                scannerService: FakeCreatureScannerService(
                    configuration: .default
                )
            )
        )
    }
}
