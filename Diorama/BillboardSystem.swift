//
//  BillboardSystem.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/03.
//

import ARKit
import RealityKit
import SwiftUI

public struct BillboardSystem: System {
    static let query = EntityQuery(where: .has(RealityKitContent.))
}
