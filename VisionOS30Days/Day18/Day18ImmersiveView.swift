//
//  Day18ImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI
import RealityKit

struct Day18ImmersiveView: View {
    
    var viewModel: Day18ViewModel
    
    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
            _ = viewModel.addText(text: "Hello World !")
        }
    }
}
