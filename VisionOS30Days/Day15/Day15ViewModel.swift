//
//  Day15ViewModel.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI
import Observation

@Observable
class Day15ViewModel {
    var selectedType: SelectionType = .guitars
    var isShowing: Bool = false
    
    enum SelectionType: String, Identifiable, CaseIterable {
        case guitars = "guitars"
        case televisions = "televisions"
        case shoes = "shoes"
        
        var id: String {
            return rawValue
        }
        
        var url: URL {
            switch self {
            case .guitars:
                return URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/stratocaster/fender_stratocaster.usdz")!
            case .televisions:
                return URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/retrotv/tv_retro.usdz")!
            case .shoes:
                return URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/nike-air-force/sneaker_airforce.usdz")!
            }
        }
        var title: String {
            switch self {
            case .guitars:
                return self.rawValue.capitalized
            case .televisions:
                return self.rawValue.capitalized
            case .shoes:
                return self.rawValue.capitalized
            }
        }
        
        var imageName: String {
            switch self {
            case .guitars:
                return "guitars"
            case .televisions:
                return "tv"
            case .shoes:
                return "shoe"
            }
        }
    }
}
