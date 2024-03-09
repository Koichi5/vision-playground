//
//  Day24ImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI
import RealityKit

struct Day24ImmersiveView: View {
    
    var viewModel: Day24ViewModel
    
    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
        }
        .onAppear() {
            viewModel.play()
        }
        .onDisappear() {
            viewModel.pause()
        }
    }
}
