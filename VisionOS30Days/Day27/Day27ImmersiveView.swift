//
//  Day27ImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI
import RealityKit

struct Day27ImmersiveView: View {
    
    var viewModel : Day27ViewModel
    
    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
        }
        .gesture(
            SpatialTapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { value in
                    viewModel.addModelEntity(value: value)
                }
        )
    }
}
