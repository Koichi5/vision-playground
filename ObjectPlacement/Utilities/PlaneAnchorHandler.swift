//
//  PlaneAnchorHandler.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import Foundation
import ARKit
import RealityKit

class PlaneAnchorHandler {
    var rootEntity: Entity
    // それぞれの Entity に紐づけられた UUID のリスト
    private var planeEntities: [UUID: Entity] = [:]
    // anchor が update された時に更新される、現在の plane anchors
    private var planeAnchorsByID: [UUID: PlaneAnchor] = [:]
    
    init(rootEntity: Entity) {
        self.rootEntity = rootEntity
    }
    
    var planeAnchors: [PlaneAnchor] {
        // planeAnchorsByID は ID が key, IDに紐づけられた PlaneAnchor が value になっているため、values を指定
        Array(planeAnchorsByID.values)
    }
    
    @MainActor
    func process(_ anchorUpdate: AnchorUpdate<PlaneAnchor>) async {
        let anchor = anchorUpdate.anchor
        
        if anchorUpdate.event == .removed {
            planeAnchorsByID.removeValue(forKey: anchor.id)
            if let entity = planeEntities.removeValue(forKey: anchor.id) {
                entity.removeFromParent()
            }
            return
        }
        
        planeAnchorsByID[anchor.id] = anchor
        
        let entity = Entity()
        entity.name = "Plane \(anchor.id)"
        entity.setTransformMatrix(anchor.originFromAnchorTransform, relativeTo: nil)
        
        var meshResource: MeshResource? = nil
        do {
            let contents = MeshResource.Contents(planeGeometry: anchor.geometry)
            meshResource = try MeshResource.generate(from: contents)
        } catch {
            print("Failed to create a mesh resource for plane anchor: \(error).")
            return
        }
        
        if let meshResource {
            // Make this plane occlude virtual objects behind it.
            entity.components.set(ModelComponent(mesh: meshResource, materials: [OcclusionMaterial()]))
        }
        
        // Generate a collision shape for the plane (for object placement and physics).
        var shape: ShapeResource? = nil
        do {
            let vertices = anchor.geometry.meshVertices.asSIMD3(ofType: Float.self)
            shape = try await ShapeResource.generateStaticMesh(positions: vertices, faceIndices: anchor.geometry.meshFaces.asUInt16Array())
        } catch {
            print("Failed to create a static mesh for a plane anchor \(error)")
            return
        }
        
        if let shape {
            var collisionGroup = PlaneAnchor.verticalCollisionGroup
            if anchor.alignment == .horizontal {
                collisionGroup = PlaneAnchor.horizontalCollisionGroup
            }
            
            entity.components.set(CollisionComponent(shapes: [shape], isStatic: true, filter: CollisionFilter(group: collisionGroup, mask: .all)))
            
            // The plane needs to be a static physics body so that objects come to rest on the plane.
            let physicsMaterial = PhysicsMaterialResource.generate()
            let physics = PhysicsBodyComponent(shapes: [shape], mass: 0.0, material: physicsMaterial, mode: .static)
            entity.components.set(physics)
        }
        
        let exsistingEntity = planeEntities[anchor.id]
        planeEntities[anchor.id] = entity
        
        rootEntity.addChild(entity)
        exsistingEntity?.removeFromParent()
    }
}
