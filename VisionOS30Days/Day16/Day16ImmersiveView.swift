//
//  Day16ImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/03/08.
//

import SwiftUI
import RealityKit
import ARKit

struct Day16ImmersiveView: View {
    
    @Environment(Day16ViewModel.self) private var model
    
    @ObservedObject var arkitSessionManager = Day16ARKitSessionManager()
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .task {
            await arkitSessionManager.startSession()
        }
        .task {
            await arkitSessionManager.handleWorldTrackingUpdates()
        }
        .task {
            await arkitSessionManager.monitorSessionEvent()
        }
        .onReceive(timer) { _ in
            arkitSessionManager.reportDevicePost()
        }
        .gesture(
            SpatialTapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { _ in
                    let matrix = arkitSessionManager.getOriginFromDeviceTransform()
                    model.addPlane(matrix: matrix)
                }
        )
        .gesture(
            LongPressGesture(minimumDuration: 1.0)
                .targetedToAnyEntity()
                .onEnded { _ in
                    model.showImmmersiveSpace.toggle()
                }
        )
    }
}
