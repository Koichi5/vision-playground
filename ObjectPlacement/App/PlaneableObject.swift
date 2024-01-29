//
//  PlanedObject.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import Foundation
import RealityKit

struct ModelDescriptor: Identifiable, Hashable {
    let fileName: String
    let displayName: String
    
    var id: String { fileName }
    
    init(fileName: String, displayName: String? = nil) {
        self.fileName = fileName
        self.displayName = displayName ?? fileName
    }
}

private enum PreviewMaterials {
    static let active = UnlitMaterial(color: .gray.withAlphaComponent(0.5))
    static let inactive = UnlitMaterial(color: .gray.withAlphaComponent(0.1))
}

@MainActor
class PlaceableObject {
    let descriptor: ModelDescriptor
    var previewEntity: Entity
    private var renderContent: ModelEntity
    
    static let previewCollisionGroup = CollisionGroup(rawValue: 1 << 15)
    
    init(descriptor: ModelDescriptor, renderContent: ModelEntity, previewEntity: Entity) {
        self.descriptor = descriptor
        self.previewEntity = previewEntity
        // init の段階で Entity が active の時の material を割り当てている。このようにして動的に material の変更が可能？
        self.previewEntity.applyMaterial(PreviewMaterials.active)
        self.renderContent = renderContent
    }
    
    var isPreviewActive: Bool = true {
        didSet {
            if oldValue != isPreviewActive {
                previewEntity.applyMaterial(isPreviewActive ? PreviewMaterials.active : PreviewMaterials.inactive)
                // ドラッグ・ジェスチャーが配置されたオブジェクトと交差するのを防ぐため、アクティブな間だけ入力ターゲットとして機能
                previewEntity.components[InputTargetComponent.self]?.allowedInputTypes = isPreviewActive ? .indirect : []
            }
        }
    }
    
    func materialize() -> PlacedObject {
        let shapes = previewEntity.components[CollisionComponent.self]!.shapes
        return PlacedObject(descriptor: descriptor, renderContentToClone: renderContent, shapes: shapes)
    }
    
    func matchesCollisionEvent(event: CollisionEvents.Began) -> Bool {
        event.entityA == previewEntity || event.entityB == previewEntity
    }
    
    func matchesCollisionEvent(event: CollisionEvents.Ended) -> Bool {
        event.entityA == previewEntity || event.entityB == previewEntity
    }
    
    func attachPreviewEntity(to entity: Entity) {
        entity.addChild(previewEntity)
    }
}

class PlacedObject: Entity {
    let fileName: String
    
    private let renderContent: ModelEntity
    static let collisionGroup = CollisionGroup(rawValue: 1 << 29)
    
    let uiOrigin = Entity()
    
    var affectedByPhysics = false {
        didSet {
            guard affectedByPhysics != oldValue else {return}
            if affectedByPhysics {
                components[PhysicsBodyComponent.self]!.mode = .dynamic
            } else {
                components[PhysicsBodyComponent.self]!.mode = .static
            }
        }
    }
    
    var isBeingDragged = false {
        didSet {
            affectedByPhysics = !isBeingDragged
        }
    }
    
    var positionAtLastReanchoringCheck: SIMD3<Float>?
    
    // detach, dragg もされていない状態？
    var atRest = false
    
    init(descriptor: ModelDescriptor, renderContentToClone: ModelEntity, shapes: [ShapeResource]) {
        fileName = descriptor.fileName
        renderContent = renderContentToClone.clone(recursive: true)
        super.init()
        name = renderContent.name
        
        scale = renderContent.scale
        renderContent.scale = .one
        
        let physicsMaterial = PhysicsMaterialResource.generate(restitution: 0.0)
        let physicsBodyComponent = PhysicsBodyComponent(shapes: shapes, mass: 1.1, material: physicsMaterial, mode: .static)
        components.set(physicsBodyComponent)
        components.set(CollisionComponent(shapes: shapes, isStatic: false, filter: CollisionFilter(group: PlacedObject.collisionGroup, mask: .all)))
        addChild(renderContent)
        addChild(uiOrigin)
        uiOrigin.position.y = extents.y / 2 // UI Origin を追加するオブジェクトの中央に配置
        
        // Allow direct and indirect manipulation of placed objects.
        components.set(InputTargetComponent(allowedInputTypes: [.direct, .indirect]))
        
        // 配置されたオブジェクトに床に投下される影を追加
        renderContent.components.set(GroundingShadowComponent(castsShadow: true))
    }
    
    required init() {
        fatalError("`init` is unimplenmented")
    }
}

extension Entity {
    func applyMaterial(_ material: Material) {
        if let modelEntity = self as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in children {
            child.applyMaterial(material)
        }
    }
    
    var extents: SIMD3<Float> { visualBounds(relativeTo: self).extents }
    
    func look(at target: SIMD3<Float>) {
        look(at: target, from: position(relativeTo: nil), relativeTo: nil, forward: .positiveZ
        )
    }
}
