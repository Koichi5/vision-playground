//
//  Day21App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI

// immersive look around app
//@main
struct Day21App: App {
    
    @State private var viewModel = Day21ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day21ContentView(viewModel: viewModel)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            Day21ImmersiveView(viewModel: viewModel)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
