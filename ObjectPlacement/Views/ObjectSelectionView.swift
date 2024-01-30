//
//  ObjectSelectionView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/30.
//

import SwiftUI

struct ObjectSelectionView: View {
    let modelDescriptors: [ModelDescriptor]
    var selectedFileName: String? = nil
    var selectionHandler: ((ModelDescriptor) -> Void)? = nil
    
    private func binding(for descriptor: ModelDescriptor) -> Binding<Bool> {
        Binding<Bool> (
            get: { selectedFileName == descriptor.fileName },
            set: { _ in
                if let selectionHandler {
                    selectionHandler(descriptor)
                }
            }
        )
    }
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose an object to place:")
                .padding(10)
            
            Grid {
                ForEach(0 ..< ((modelDescriptors.count + 1) / 2), id: \.self) { row in
                    GridRow {
                        ForEach(0 ..< 2, id: \.self) { column in
                            let descriptorIndex = row * 2 + column
                            if descriptorIndex < modelDescriptors.count {
                                let descriptor = modelDescriptors[descriptorIndex]
                                Toggle(isOn: binding(for: descriptor)) {
                                    Text(descriptor.displayName)
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .lineLimit(1)
                                }
                                .toggleStyle(.button)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .plain) {
    ObjectSelectionView(
        modelDescriptors: AppState.previewAppState().modelDescriptors,
        selectedFileName: AppState.previewAppState().modelDescriptors[0].fileName
    )
    .padding(20)
    .frame(width: 400)
    .glassBackgroundEffect()
}
