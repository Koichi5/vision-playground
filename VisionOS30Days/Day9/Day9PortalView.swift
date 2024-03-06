//
//  Day9PortalView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct Day9PortalView: View {
    var body: some View {
        RealityView { content in
            let world = makeWorld()
            let portal = makePortal(world: world)
            content.add(world)
            content.add(portal)
        }
    }
    
    func makeWorld() -> Entity {
        let world = Entity()
        world.components[WorldComponent.self] = .init()
        
//        let environment = try! EnvironmentResource.load(named: "Sunlight")
//        world.components[ImageBasedLightComponent.self] = .init(source: .single(environment), intensityExponent: 12)
//        world.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: world)
        
        guard let earth = try? ModelEntity.load(named: "Earth", in: RealityKitContentBundle) else { fatalError("No entity found") }
        earth.position = SIMD3<Float>(x: -0.1, y: 0, z: -0.4)
        world.addChild(earth)
        
        return world
    }
    
    func makePortal(world: Entity) -> Entity {
        let portal = Entity()
        
        portal.components[ModelComponent.self] = .init(mesh: .generatePlane(width: 0.5, height: 0.5, cornerRadius: 0.5), materials: [PortalMaterial()])
        portal.components[PortalComponent.self] = .init(target: world)
        
        return portal
    }
}

#Preview {
    Day9PortalView()
}
