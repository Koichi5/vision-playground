//
//  Day27SwiftUISampleView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/10.
//

import SwiftUI

struct Day27SwiftUISampleView: View {
    
    var viewModel = Day27ViewModel()
    
    var body: some View {
        viewToSnapshot()
    }
    
    func viewToSnapshot() -> some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red)
                    .overlay(
                        VStack {
                            Text("Source SwiftUI View")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                            Text("X: \(geometry.frame(in: .global).origin.x) Y: \(geometry.frame(in: .global).origin.y) width: \(geometry.frame(in: .global).width) height: \(geometry.frame(in: .global).height)")
                                .foregroundStyle(.white)
                        }
                    )
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
    }
    
    @MainActor
    func generateSnapshot() async {
        let renderer = ImageRenderer(content: viewToSnapshot())
        if let image = renderer.uiImage {
            viewModel.targetSnapshot = image
        }
    }
}


#Preview {
    Day27SwiftUISampleView()
}
