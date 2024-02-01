//
//  WallPlacement.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/31.
//

import SwiftUI
import RealityKit

struct WallPlacement: View {
    var body: some View {
        RealityView { content in
            let anchor = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: [1,1]))
            content.add(anchor)
            
            if let entity = try? await Entity(named: "Box") {
                let radians = -90.0 * Float.pi / 180.0
                entity.transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(1,0,0))
                entity.scale = [0.025, 0.025, 0.025]
                anchor.addChild(entity)
            }
        }
    }
}

//#Preview {
//    WallPlacement()
//}
