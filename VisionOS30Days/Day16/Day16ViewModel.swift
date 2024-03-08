//
//  Day16ViewModel.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI
import RealityKit
import Observation

@Observable
class Day16ViewModel {
    var showImmmersiveSpace = false
    
    private var contentEntity = Entity()
    private let placeOffset: SIMD3<Float> = .init(x: 0.0, y: 0.0, z: 0.0)
    
    func setupContentEntity() -> Entity {
        contentEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        contentEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 20)], isStatic: true))
        return contentEntity
    }
    
    func addPlane(matrix: simd_float4x4) {
        let entity = try! Entity.load(named: "Scene")
//        entity.scale *= 5
        entity.position = matrix.position + placeOffset
        entity.orientation = matrix.orientation
        contentEntity.addChild(entity)
    }
}
