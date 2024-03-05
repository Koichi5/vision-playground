//
//  Day5ImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI
import RealityKit

struct Day5ImmersiveView: View {
    
    @StateObject var model = Day5ViewModel()
    
    private var contentEntity = Entity()
    private var location: CGPoint = .zero
    private var location3D: Point3D = .zero
    
    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
            model.addCube()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    print(value)
                }
        )
    }
}

#Preview {
    Day5ImmersiveView()
}
