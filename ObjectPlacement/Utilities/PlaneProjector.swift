//
//  PlaneProjector.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/29.
//

import Foundation
import ARKit
import RealityKit

enum PlaneProjector {
    static func project(point originFromPointTransform: matrix_float4x4, ontoHorizontalPlaneIn planeAnchors: [PlaneAnchor], withMaxDistance: Float) -> matrix_float4x4? {
        // 水平の平面のみに限定
        let horizontalPlanes = planeAnchors.filter({ $0.alignment == .horizontal })
        
        // 与えられた最大の大きさに収まること
        let inVerticalRangePlanes = horizontalPlanes.within(meters: withMaxDistance, of: originFromPointTransform)
        
        // 与えられたポイント、平面上に投影されたものがポイントの geometry に収まること
        let matchingPlanes = inVerticalRangePlanes.containing(pointToProject: originFromPointTransform)
        
        // 全ての条件に合う平面のうち、最もユーザーに近いもの
        if let closestPlane = matchingPlanes.closestPlane(to: originFromPointTransform) {
            var result = originFromPointTransform
            result.translation = [originFromPointTransform.translation.x, closestPlane.originFromAnchorTransform.translation.y, originFromPointTransform.translation.z]
            return result
        }
        return nil
    }
}

extension Array where Element == PlaneAnchor {
    // それぞれの平面が、与えられてポイントから大きく離れていないかフィルタリング
    func within(meters maxDistance: Float, of originFromGivenPointTransform: matrix_float4x4) -> [PlaneAnchor] {
        var matchingPlanes: [PlaneAnchor] = []
        let originFromGivenPointY = originFromGivenPointTransform.translation.y
        for anchor in self {
            let originFromPlaneY = anchor.originFromAnchorTransform.translation.y
            let distance = abs(originFromGivenPointY - originFromPlaneY)
            if distance <= maxDistance {
                matchingPlanes.append(anchor)
            }
        }
        return matchingPlanes
    }
    
    func closestPlane(to originFromGivenPointTransform: matrix_float4x4) -> PlaneAnchor? {
        var shortestDistance = Float.greatestFiniteMagnitude
        var closestPlane: PlaneAnchor?
        let originFromGivenPointY = originFromGivenPointTransform.translation.y
        for anchor in self {
            let originFromPlaneY = anchor.originFromAnchorTransform.translation.y
            let distance = abs(originFromGivenPointY - originFromPlaneY)
            if distance < shortestDistance {
                shortestDistance = distance
                closestPlane = anchor
            }
        }
        return closestPlane
    }
    
    func containing(pointToProject originFromGivenPointTransform: matrix_float4x4) -> [PlaneAnchor] {
        var matchingPlanes: [PlaneAnchor] = []
        for anchor in self {
            // 与えられたポイントを2D上に投影
            let planeAnchorFromOriginTransform = simd_inverse(anchor.originFromAnchorTransform)
            let planeAnchorFromPointTransform = planeAnchorFromOriginTransform * originFromGivenPointTransform
            let planeAnchorFromPoint2D: SIMD2<Float> = [planeAnchorFromPointTransform.translation.x, planeAnchorFromPointTransform.translation.z]
            
            var insidePlaneGeometry = false
            
            let faceCount = anchor.geometry.meshFaces.count
            for faceIndex in 0..<faceCount {
                let vertexIndicesForThisFace = anchor.geometry.meshFaces[faceIndex]
                let vertex1 = anchor.geometry.meshVertices[vertexIndicesForThisFace[0]]
                let vertex2 = anchor.geometry.meshVertices[vertexIndicesForThisFace[1]]
                let vertex3 = anchor.geometry.meshVertices[vertexIndicesForThisFace[2]]
                
                insidePlaneGeometry = planeAnchorFromPoint2D.isInsideOf([vertex1.0, vertex1.2], [vertex2.0, vertex2.2], [vertex3.0, vertex3.2])
                if insidePlaneGeometry {
                    matchingPlanes.append(anchor)
                    break
                }
            }
        }
        return matchingPlanes
    }
}
