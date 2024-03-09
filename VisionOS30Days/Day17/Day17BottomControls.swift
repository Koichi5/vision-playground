//
//  Day17BottomControls.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/09.
//

import SwiftUI

struct Day17BottomControls: View {
    
    var viewModel: Day17ViewModel
    
    @State private var isPickerVisible: Bool = false
    @State private var isRotationPickerVisible: Bool = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(alignment: .scaleButtonGuide) {
            HStack(spacing: 17) {
                Toggle(isOn: $viewModel.isTransparent) {
                    Label("Transparent", systemImage: "cube.transparent")
                }
                .help("Transparent")
                
                Toggle(isOn: $isPickerVisible) {
                    Label("Scale", systemImage: "scale.3d")
                }
                .help("Scale")
                .alignmentGuide(.scaleButtonGuide) { context in
                    context[HorizontalAlignment.center]
                }
                
                Toggle(isOn: $isRotationPickerVisible) {
                    Label("Rotation", systemImage: "rotate.3d")
                }
                .help("Rotation")
                .alignmentGuide(.scaleButtonGuide) { context in
                    context[HorizontalAlignment.center]
                }
            }
            .toggleStyle(.button)
            .buttonStyle(.borderless)
            .padding(12)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
            .alignmentGuide(.controlPanelGuide) { context in
                context[HorizontalAlignment.center]
            }
            HStack {
                ScalePicker(viewModel: viewModel, isVisible: $isPickerVisible)
                    .alignmentGuide(.scaleButtonGuide) { context in
                        context[HorizontalAlignment.center]
                    }
                RotationPicker(viewModel: viewModel, isRotationPickerVisible: $isRotationPickerVisible)
                    .alignmentGuide(.scaleButtonGuide) { context in
                        context[HorizontalAlignment.center]
                    }
            }
        }
        .onChange(of: viewModel.isTransparent) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.updateTransparency()
            }
        }
        .onChange(of: viewModel.selectedScale) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.updateScale()
            }
        }
        .onChange(of: viewModel.selectedRotation) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.updateRotation()
            }
        }
    }
}

private struct ScalePicker: View {
    var viewModel: Day17ViewModel
    
    @Binding var isVisible: Bool
    
    var body: some View {
        Grid(alignment: .leading) {
            Text("Scale")
                .font(.title)
                .padding(.top, 5)
                .gridCellAnchor(.center)
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            ForEach(Scales.allCases) { scale in
                GridRow {
                    Button {
                        viewModel.selectedScale = scale
                        isVisible = false
                    } label: {
                        Text(scale.name)
                    }
                    .buttonStyle(.borderless)
                    
                    Image(systemName: "checkmark")
                        .opacity(scale == viewModel.selectedScale ? 1 : 0)
                }
            }
        }
        .padding(12)
        .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        .opacity(isVisible ? 1 : 0)
        .animation(.default.speed(2), value: isVisible)
    }
}

private struct RotationPicker: View {
    var viewModel: Day17ViewModel
    
    @Binding var isRotationPickerVisible: Bool
    
    var body: some View {
        Grid(alignment: .leading) {
            Text("Rotation")
                .font(.title)
                .padding(.top, 5)
                .gridCellAnchor(.center)
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            ForEach(Rotation.allCases) { rotation in
                GridRow {
                    Button {
                        viewModel.selectedRotation = rotation
                        isRotationPickerVisible = false
                    } label: {
                        Text(rotation.name)
                    }
                    .buttonStyle(.borderless)
                    
                    Image(systemName: "checkmark")
                        .opacity(rotation == viewModel.selectedRotation ? 1 : 0)
                }
            }
        }
        .padding(12)
        .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        .opacity(isRotationPickerVisible ? 1 : 0)
        .animation(.default.speed(2), value: isRotationPickerVisible)
    }
}

extension HorizontalAlignment {
    private struct ControlPanelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }
    
    private struct ScaleButtonAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }
    
    static let controlPanelGuide = HorizontalAlignment(ControlPanelAlignment.self)
    
    fileprivate static let scaleButtonGuide = HorizontalAlignment(ScaleButtonAlignment.self)
}


