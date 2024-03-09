//
//  Day17ViewModel.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI
import Observation
import RealityKit

@Observable
class Day17ViewModel {
    var cubeEntity: ModelEntity? = nil
    
    var isTransparent: Bool = false
    var selectedScale: Scales = .medium
    var selectedRotation: Rotation = .degree0
    
    var simpleMaterial: RealityKit.Material {
        let texture1 = try! TextureResource.load(named: "aurora")
        var simpleMaterial = SimpleMaterial()
        simpleMaterial.color = .init(tint: .white, texture: .init(texture1))
        return simpleMaterial
    }
    
    var unlitMaterial: RealityKit.Material {
        let texture1 = try! TextureResource.load(named: "aurora")
        var unlitMaterial = UnlitMaterial()
        unlitMaterial.color = .init(tint: .white, texture: .init(texture1))
        unlitMaterial.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: 1.0))
        return unlitMaterial
    }
    
    func updateTransparency() {
        if let cubeEntity = cubeEntity {
            let materials = isTransparent ? [unlitMaterial] : [simpleMaterial]
            cubeEntity.model?.materials = materials
        }
    }
    
    func updateScale() {
        if let cubeEntity = cubeEntity {
            let newScale = selectedScale.scaleValue
            cubeEntity.setScale(SIMD3<Float>(repeating: newScale), relativeTo: nil)
        }
    }
    
    func updateRotation() {
        if let cubeEntity = cubeEntity {
            let newScale = selectedRotation.rotationValue
            cubeEntity.setOrientation(simd_quatf(angle: selectedRotation.rotationValue, axis: SIMD3<Float>(x: 0, y: 1, z: 0)), relativeTo: nil)
        }
    }
}

enum Scales: String, CaseIterable, Identifiable {
    case verySmall, small, medium, large, veryLarge
    var id: Self { self }
    
    var name: String {
        switch self {
        case .verySmall: "Very small"
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        case .veryLarge: "Very Large"
        }
    }
    
    var scaleValue: Float {
        switch self {
        case .verySmall: 0.3
        case .small: 0.5
        case .medium: 1.0
        case .large: 1.5
        case .veryLarge: 1.8
        }
    }
}

enum Rotation: String, CaseIterable, Identifiable {
    case degree0, degree45, degree90, degree180
    var id: Self { self }
    
    var name: String {
        switch self {
        case .degree0: "0°"
        case .degree45: "45°"
        case .degree90: "90°"
        case .degree180: "180°"
        }
    }
    
    var rotationValue: Float {
        switch self {
        case .degree0: 0
        case .degree45: 45
        case .degree90: 90
        case .degree180: 180
        }
    }
}
