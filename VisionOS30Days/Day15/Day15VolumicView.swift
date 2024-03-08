//
//  Day15VolumicView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI
import RealityKit

struct Day15VolumicView: View {
    
    @Environment(Day15ViewModel.self) private var model
    var body: some View {
        VStack {
            Model3D(url: model.selectedType.url) { model in
                model
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .onDisappear {
                model.isShowing = false
            }
            .onTapGesture {
                print("\(model.selectedType.title) is tapped")
            }
        }
    }
}

#Preview {
    Day15VolumicView()
}
