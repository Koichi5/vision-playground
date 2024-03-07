//
//  Day11App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

@main
struct Day11App: App {
    
    @State private var model = Day11ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day11ContentView()
                .environment(model)
        }
    }
}

//#Preview {
//    Day11App()
//}
