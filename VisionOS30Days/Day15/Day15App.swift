//
//  Day15App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

//@main
struct Day15App: App {
    
    @State private var model = Day15ViewModel()
    
    var body: some Scene {
        WindowGroup("home") {
            Day15HomeView()
                .environment(model)
        }
        .windowStyle(.plain)
        
        WindowGroup(id: "model") {
            Day15VolumicView()
                .environment(model)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
    }
}
