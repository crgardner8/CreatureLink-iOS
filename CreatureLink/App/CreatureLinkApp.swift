//
//  CreatureLinkApp.swift
//  CreatureLink
//
//  Created by Clifton Gardner on 4/16/26.
//

import SwiftUI

@main
struct CreatureLinkApp: App {
    var body: some Scene {
        WindowGroup {
            CreatureListView(
                viewModel: CreatureListViewModel(
                    scannerService: FakeCreatureScannerService(
                        configuration: .default
                    )
                )
            )
        }
    }
}
