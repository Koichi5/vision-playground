//
//  FlockingComponent.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/09.
//

import RealityKit

public struct FlockingComponent: Component, Codable {
    public var velocity = SIMD3<Float>(repeating: 0.0)
    public var seekPosition = SIMD3<Float>(0.0, 1.5, 0.0)
    
    public init() {}
}
