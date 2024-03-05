//
//  Day6ContentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/06.
//

import SwiftUI

struct Day6ContentView: View {
    
    @State var showImmersiveSpace = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                    .toggleStyle(.button)
            }
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
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

#Preview {
    Day6ContentView()
}
