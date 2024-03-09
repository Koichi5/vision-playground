//
//  Day24ContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI
import RealityKit

struct Day24ContentView: View {
    
    var viewModel: Day24ViewModel
    
    @State private var showImmersiceSpace = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle("Show ImmersiveSpace", isOn: $showImmersiceSpace)
                    .toggleStyle(.button)
            }
        }
        .onChange(of: showImmersiceSpace) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
}
