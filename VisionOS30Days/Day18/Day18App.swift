//
//  Day18App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI

// 3d text app
//@main
struct Day18App: App {
    
    @State private var viewModel = Day18ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day18ContentView()
        }
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            Day18ImmersiveView(viewModel: viewModel)
        }
    }
}
