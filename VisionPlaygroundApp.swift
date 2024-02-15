//
//  VisionPlaygroundApp.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import SwiftUI

// for ObjectPlacement
//private enum UIIdentifier {
//    static let immersiveSpace = "Object Placement"
//}
//
//@main
//@MainActor
//struct VisionPlaygroundApp: App {
//    @State private var appState = AppState()
//    @State private var modelLoader = ModelLoader()
//    
//    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
//    @Environment(\.scenePhase) private var scenePhase
//
//    var body: some SwiftUI.Scene {
//        WindowGroup {
//            HomeView(
//                appState: appState,
//                modelLoader: modelLoader,
//                immersiveSpaceIdentifier: UIIdentifier.immersiveSpace
//            )
//                .task {
//                    await modelLoader.loadObjects()
//                    appState.setPlaceableObjects(modelLoader.placeableObjects)
//                }
//        }
//        .windowResizability(.contentSize)
//        .windowStyle(.plain)
//
//        ImmersiveSpace(id: UIIdentifier.immersiveSpace) {
//            ObjectPlacementRealityView(appState: appState)
//        }
//        .onChange(of: scenePhase, initial: true) {
//            if scenePhase != .active {
//                // Leave the immersive space when the user dismisses the app.
//                if appState.immersiveSpaceOpened {
//                    Task {
//                        await dismissImmersiveSpace()
//                        appState.didLeaveImmersiveSpace()
//                    }
//                }
//            }
//        }
//    }
//}

// for WallPlacement
//@main
//@MainActor
//struct VisionPlaygroundApp: App {
//    @State private var immersionStyle: ImmersionStyle = .mixed
//
//    var body: some Scene {
//        WindowGroup {
//            WallPlacementContentView()
//        }
////        .windowStyle(.volumetric)
//        
//        ImmersiveSpace(id: "ImmersiveSpace") {
//            WallPlacement()
//        }
//        .immersionStyle(selection: $immersionStyle, in: .mixed)
//    }
//}

// for ImmersiveSpaceSample
//import SwiftUI
//
//@main
//struct VisionPlaygroundApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ImmersiveSpaceSampleContentView()
//        }
//
//        ImmersiveSpace(id: "ImmersiveSpace") {
//            ImmersiveSpaceSampleImmersiveView()
//        }.immersionStyle(selection: .constant(.full), in: .full)
//    }
//}

// for Diorama
import SwiftUI
import RealityKitContent
import ARKit
import RealityKit

@main
struct VisionPlaygroundApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let immersiveSpaceIdentifier = "Immersive"
    
    @State private var viewModel = DioramaViewModel()

    init() {
        RealityKitContent.PointOfInterestComponent.registerComponent()
        PointOfInterestRuntimeComponent.registerComponent()
        RealityKitContent.TrailComponent.registerComponent()
        RealityKitContent.BillboardComponent.registerComponent()
        ControlledOpacityComponent.registerComponent()
        RealityKitContent.RegionSpecificComponent.registerComponent()
        
        RealityKitContent.BillboardSystem.registerSystem()
        RealityKitContent.TrailAnimationSystem.registerSystem()

        FlockingComponent.registerComponent()
        FlockingSystem.registerSystem()
    }
    
    var body: some SwiftUI.Scene {

        WindowGroup {
            DioramaContentView(spaceId: immersiveSpaceIdentifier,
                        viewModel: viewModel)
        }
        .windowStyle(.plain)

        ImmersiveSpace(id: immersiveSpaceIdentifier) {
            DioramaView(viewModel: viewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: UIApplication) -> Bool {
        return true
    }
}
