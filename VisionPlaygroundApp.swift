//
//  VisionPlaygroundApp.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import SwiftUI

@main
struct VisionPlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
