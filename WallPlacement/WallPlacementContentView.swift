//
//  WallPlacementContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/31.
//

import SwiftUI

struct WallPlacementContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
//    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    var body: some View {
        Button(action:  {
            Task {
                await openImmersiveSpace(id: "ImmersiveSpace")
            }
        }) {
            Text("Open Immersive Space")
        }
    }
}

#Preview {
    WallPlacementContentView()
}
