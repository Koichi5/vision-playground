//
//  DragState.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/29.
//

import Foundation

struct DragState {
    var draggedObject: PlacedObject
    var initialPosition: SIMD3<Float>
    
    @MainActor
    init(objectToDrag: PlacedObject) {
        draggedObject = objectToDrag
        initialPosition = objectToDrag.position
    }
}
