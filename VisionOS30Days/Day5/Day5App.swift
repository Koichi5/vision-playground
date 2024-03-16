//
//  Day5App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI

// textured box app
//@main
struct Day5App: App {
    var body: some Scene {
        WindowGroup() {
            Day5ContentView()
        }
        ImmersiveSpace(id: "ImmersiveSpace") {
            Day5ImmersiveView()
        }
    }
}
