//
//  PlacementState.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/29.
//

import Foundation
import RealityKit

@Observable
class PlacementState {
    var selectedObject: PlaceableObject? = nil
    var highlightedObject: PlacedObject? = nil
    var objectToPlace: PlaceableObject? { isPlacementPossible ?
        selectedObject : nil
    }
    var userDraggedAnObject = false
    var planeToProjectOnFound = false
    var activeCollisions = 0
    var collisionDetected: Bool { activeCollisions > 0 }
    var dragInProgress = false
    var userPlacedAnObject = false
    var deviceAnchorPresent = false
    var planeAnchorsPresent = false
    
    var shouldShowPreview: Bool {
        return deviceAnchorPresent && planeAnchorsPresent && !dragInProgress && highlightedObject == nil
    }
    
    var isPlacementPossible: Bool {
        return selectedObject != nil && shouldShowPreview && planeToProjectOnFound && !collisionDetected && !dragInProgress
    }
}
