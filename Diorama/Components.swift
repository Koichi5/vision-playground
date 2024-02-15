//
//  Components.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/09.
//

import RealityKit
import RealityKitContent

struct PointOfInterestRuntimeComponent: Component {
    let attachmentTag: ObjectIdentifier
}

struct ControlledOpacityComponent: Component {
    var shouldShow: Bool = false
    
    func opacity(forSliderValue sliderValue: Float) -> Float {
        if !shouldShow {
            return 0.0
        } else {
            return sliderValue
        }
    }
}
