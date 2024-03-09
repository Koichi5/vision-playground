//
//  Day21ImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI
import RealityKit

struct Day21ImmersiveView: View {
    
    var viewModel: Day21ViewModel
    
    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
        }
        .task {
            try? await viewModel.setSnapshot()
        }
    }
}
