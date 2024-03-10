//
//  Day25App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI

//@main
struct Day25App: App {
    
    @State private var viewModel = Day25ViewModel()
    
    var body: some Scene {
        WindowGroup("", id: "home") {
            Day25ContentView(viewModel: viewModel)
        }
        .defaultSize(width: 480, height: 640)
        
        WindowGroup("", id: "other") {
            Day25ContentViewOther(viewModel: viewModel)
        }
        .defaultSize(width: 480, height: 640)
    }
}
