//
//  Day16App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

//@main
struct Day16App: App {
    
    @State private var model = Day16ViewModel()
    
    var body: some Scene {
        WindowGroup {
            Day16CotntentView()
                .environment(model)
        }
        
        ImmersiveSpace(id: "Day16ImmersiveSpace") {
            Day16ImmersiveView()
                .environment(model)
        }
    }
}
