//
//  Day10App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI

// Preferred Default Scene Session Role: Window Application Session Role
//@main
struct Day10App: App {
    var body: some Scene {
        WindowGroup {
            Day10ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            Day10ImmersiveSpace()
        }
    }
}
