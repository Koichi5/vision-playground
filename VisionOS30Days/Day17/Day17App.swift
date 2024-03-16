//
//  Day17App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI

// ornament app
//@main
struct Day17App: App {
    @State private var viewModel = Day17ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day17ContentView(viewModel: viewModel)
        }
    }
}
