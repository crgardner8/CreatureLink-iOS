//
//  CreatureRowView.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import SwiftUI

struct CreatureRowView: View {
    let creature: Creature
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(creature.name)
                    .font(.headline)
                
                Text("\(creature.type.rawValue.capitalized) • Mood: \(creature.mood.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Signal: \(creature.signalStrength)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("⚡ \(creature.energy)")
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

struct CreatureRowView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureRowView(
            creature: Creature(
                id: UUID(),
                name: "EmberFox",
                type: .fire,
                energy: 82,
                mood: .excited,
                signalStrength: 88,
                isConnected: false
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
