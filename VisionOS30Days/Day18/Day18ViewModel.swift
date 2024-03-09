//
//  Day18ViewModel.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI
import RealityKit
import Observation

@Observable
class Day18ViewModel {
    private var contentEntity = Entity()
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    
    func addText(text: String) -> Entity {
        
        let textMeshResource: MeshResource = .generateText(
            text,
            extrusionDepth: 0.05,
            font: .systemFont(ofSize: 0.3),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let sphereMeshResource: MeshResource = .generateSphere(radius: 1)
        
        let material = UnlitMaterial(color: .white)
        
        let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
        textEntity.position = SIMD3(x: -(textMeshResource.bounds.extents.x / 2), y: 1.5, z: -2)
        
        let sphereEntity = ModelEntity(mesh: sphereMeshResource)
        
        contentEntity.addChild(textEntity)
        contentEntity.addChild(sphereEntity)
        
        return textEntity
    }
}
