//
//  Day27ViewModel.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import Observation
import RealityKit
import SwiftUI

@Observable
class Day27ViewModel {
    
    private var contentEntity = Entity()
    var targetSnapshot: UIImage? = nil
    
    func setupContentEntity() -> Entity {
        contentEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        
        contentEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 1E2)], isStatic: true))
        
        return contentEntity
    }
    
    func addModelEntity(value: EntityTargetValue<SpatialTapGesture.Value>) {
        let modelEntity = ModelEntity(mesh: MeshResource.generatePlane(width: Float(targetSize.width) * 0.001, depth: Float(targetSize.height) * 0.001))
        modelEntity.generateCollisionShapes(recursive: true)
        modelEntity.model?.materials = [createTexture()]
        modelEntity.position = value.convert(value.location3D, from: .local, to: .scene)
        contentEntity.addChild(modelEntity)
    }
    
    func createTexture() -> UnlitMaterial {
        guard let snapshot = targetSnapshot else { return UnlitMaterial(color: .black) }
        let texture = try! TextureResource.generate(from: snapshot.cgImage!, options: .init(semantic: .color))
        
        var material = UnlitMaterial()
        
        material.color = .init(tint: .white, texture: .init(texture))
        
        material.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: 2.0))
        
        return material
    }
}

