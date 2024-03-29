//
//  Day4App.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI
import RealityKit

// place box app
//@main
struct Day4App: App {
    
    @StateObject var model = Day4ViewModel()
    
    var body: some SwiftUI.Scene {
        ImmersiveSpace {
            RealityView { content in
                content.add(model.setupContentEntity())
            }
            .task {
                print("day4 app task fired")
                await model.runSession()
            }
        }
    }
}
