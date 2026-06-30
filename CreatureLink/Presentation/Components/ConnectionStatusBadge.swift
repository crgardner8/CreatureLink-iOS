//
//  ConnectionStatusBadge.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/17/26.
//

import SwiftUI

struct ConnectionStatusBadge: View {
    let state: ConnectionState
    
    var body: some View {
        Text(title)
            .font(.caption)
            .bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.15))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }
    
    private var title: String {
        switch state {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .reconnecting:
            return "Reconnecting"
        case .unavailable:
            return "Unavailable"
        case .failed:
            return "Failed"
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .disconnected:
            return .gray
        case .connecting:
            return .orange
        case .connected:
            return .green
        case .reconnecting:
            return .blue
        case .unavailable:
            return .purple
        case .failed:
            return .red
        }
    }
}

struct ConnectionStatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            ConnectionStatusBadge(state: .disconnected)
            ConnectionStatusBadge(state: .connecting)
            ConnectionStatusBadge(state: .connected)
            ConnectionStatusBadge(state: .reconnecting)
            ConnectionStatusBadge(state: .unavailable)
            ConnectionStatusBadge(state: .failed("Example"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
