//
//  Day27App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI

// swiftui view in immersive space
@main
struct Day27App: App {
    
    @State private var viewModel = Day27ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day27ContentView(viewModel: viewModel)
        }
        .defaultSize(width: windowTargetSize.width, height: windowTargetSize.height)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            Day27ImmersiveView(viewModel: viewModel)
        }
    }
}
