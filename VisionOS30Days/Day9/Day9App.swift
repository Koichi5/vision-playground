//
//  Day9App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI

// portal app
// On Info file:  Preferred Default Scene Session Role: Volumetric Window Application Session Role
//@main
struct Day9App: App {
    var body: some Scene {
        WindowGroup {
            Day9PortalView()
        }
        .windowStyle(.volumetric)
    }
}
