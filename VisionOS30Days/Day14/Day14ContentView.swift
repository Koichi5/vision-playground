//
//  Day14ContentVIew.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

struct Day14ContentView: View {
    
    @State var showImmersiveSpace_Progressive = false
    @State var showImmersiveSpace_Full = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle("Show Progressive Immersive Space", isOn: $showImmersiveSpace_Progressive)
                    .toggleStyle(.button)
                    .disabled(progressiveIsValid)
                
                Toggle("Show Full Immersive Space", isOn: $showImmersiveSpace_Full)
                    .toggleStyle(.button)
                    .disabled(fullIsValid)
                    .padding(.top, 50)
            }
        }
        .onChange(of: showImmersiveSpace_Progressive) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace_Progressive")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
        .onChange(of: showImmersiveSpace_Full) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace_Full")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
    
    var progressiveIsValid: Bool {
        return showImmersiveSpace_Full
    }
    
    var fullIsValid: Bool {
        return showImmersiveSpace_Progressive
    }
}

#Preview {
    Day14ContentView()
}
