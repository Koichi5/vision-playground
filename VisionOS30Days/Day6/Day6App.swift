//
//  Day6App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI

// drag and drop app
//@main
struct Day6App: App {
    var body: some Scene {
        WindowGroup {
            Day6ContentView()
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            Day6ImmersiveView()
        }
    }
}
