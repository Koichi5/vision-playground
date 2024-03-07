//
//  Day10ImmersiveSpace.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI
import RealityKit

struct Day10ImmersiveSpace: View {
    
    @State var model = Day10ViewModel()
    
    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .onTapGesture {
            model.toggleSorted()
        }
    }
}

#Preview {
    Day10ImmersiveSpace()
}
