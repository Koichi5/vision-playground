//
//  ImmersiveSpaceSampleContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/01.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveSpaceSampleContentView: View {
    let labelSharedSpace = "Shared Space"
    let labelFullImmersiveSpace = "Full Immersive Space"
    
    @State var showImmersiveSpace = false
    @State var message = "Shared Space"
    @State var buttonLabel = "Full Immersive Space"

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
       VStack {
           Model3D(named: "Scene", bundle: RealityKitContentBundle)
           .padding(.bottom, 50)

           Text(message)
           Toggle("Show " + buttonLabel, isOn: $showImmersiveSpace)
               .toggleStyle(.button)
               .padding(.top, 50)
               .onChange(of: showImmersiveSpace) { _, newValue in
               Task {
                   if newValue {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                        message = labelFullImmersiveSpace
                        buttonLabel = labelSharedSpace
                    } else {
                        await dismissImmersiveSpace()
                        message = labelSharedSpace
                        buttonLabel = labelFullImmersiveSpace
                    }
                }
            }
       }
    }
}

#Preview {
    ImmersiveSpaceSampleContentView()
}
