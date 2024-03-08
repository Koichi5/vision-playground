//
//  Day16CotntentView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI

struct Day16CotntentView: View {
    
    @Environment(Day16ViewModel.self) private var model
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        @Bindable var model = model
        
        NavigationStack {
            Toggle(model.showImmmersiveSpace ? "LongPress to Dismiss" : "Show ImmersiveSpace", isOn: $model.showImmmersiveSpace)
                .toggleStyle(.button)
        }
        .onChange(of: model.showImmmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "Day16ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
}
