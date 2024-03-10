//
//  Day24App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI

//@main
struct Day24App: App {
    
    @State private var viewModel = Day24ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day24ContentView(viewModel: viewModel)
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            Day24ImmersiveView(viewModel: viewModel)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
