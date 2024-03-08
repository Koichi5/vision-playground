//
//  Day14App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

//@main
struct Day14App: App {
    var body: some Scene {
        WindowGroup {
            Day14ContentView()
        }
        
        ImmersiveSpace(id: "ImmersiveSpace_Progressive") {
            Day14ImmersiveSpace(imageName: "park_scene")
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        
        ImmersiveSpace(id: "ImmersiveSpace_Full") {
            Day14ImmersiveSpace(imageName: "beach_scene")
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

//#Preview {
//    Day14App()
//}
