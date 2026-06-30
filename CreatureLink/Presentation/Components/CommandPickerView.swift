//
//  CommandPickerView.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/27/26.
//

import SwiftUI

struct CommandPickerView: View {
    @Binding var selectedCommand: CreatureCommand
    
    var body: some View {
        Picker("Command", selection: $selectedCommand) {
            ForEach(CreatureCommand.allCases) { command in
                Text(command.displayTitle)
                    .tag(command)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct CommandPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CommandPickerView(selectedCommand: .constant(.feed))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
