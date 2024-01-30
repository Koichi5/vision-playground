//
//  VisionPlaygroundApp.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import SwiftUI

private enum UIIdentifier {
    static let immersiveSpace = "Object Placement"
}

@main
@MainActor
struct VisionPlaygroundApp: App {
    @State private var appState = AppState()
    @State private var modelLoader = ModelLoader()
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some SwiftUI.Scene {
        WindowGroup {
            HomeView(
                appState: appState,
                modelLoader: modelLoader,
                immersiveSpaceIdentifier: UIIdentifier.immersiveSpace
            )
                .task {
                    await modelLoader.loadObjects()
                    appState.setPlaceableObjects(modelLoader.placeableObjects)
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.plain)

        ImmersiveSpace(id: UIIdentifier.immersiveSpace) {
            ObjectPlacementRealityView(appState: appState)
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                // Leave the immersive space when the user dismisses the app.
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
    }
}
