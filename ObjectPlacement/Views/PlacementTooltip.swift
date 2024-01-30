//
//  PlacementTooltip.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/30.
//

import SwiftUI

struct PlacementTooltip: View {
    var placementState: PlacementState
    
    var body: some View {
        if let message {
            TooltipView(text: message)
        }
    }
    
    var message: String? {
        if !placementState.planeToProjectOnFound {
            return "Point the device at a horizontal surface nerby,"
        }
        if placementState.collisionDetected {
            return "The space is occupied."
        }
        if !placementState.userPlacedAnObject {
            return "Tap tp place objects."
        }
        return nil
    }
}

#Preview(windowStyle: .plain) {
    VStack {
        PlacementTooltip(placementState: PlacementState())
        PlacementTooltip(placementState: PlacementState().withPlaneFound())
        PlacementTooltip(placementState:
            PlacementState()
                .withPlaneFound()
                .withCollisionDetected()
        )
    }
}

private extension PlacementState {
    func withPlaneFound() -> PlacementState {
        planeToProjectOnFound = true
        return self
    }
    
    func withCollisionDetected() -> PlacementState {
        activeCollisions = 1
        return self
    }
}
