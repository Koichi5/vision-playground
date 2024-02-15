//
//  DioramaApp.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/02.
//

//import SwiftUI
//import RealityKit
//import RealityKitContent
//import ARKit
//
//@main
//struct DioramaApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    private let immersiveSpaceIdentifier = "Immersive"
//    
//    @State private var viewModel = DioramaViewModel()
//    
//    init() {
//        RealityKitContent.PointOfInterestComponent.registerComponent()
//        PointOfInterestRuntimeComponent.registerComponent()
//        RealityKitContent.TrailComponent.registerComponent()
//        RealityKitContent.BillboardComponent.registerComponent()
//        ControlledOpacityComponent.registerComponent()
//        RealityKitContent.RegionSpecificComponent.registerComponent()
//        
//        RealityKitContent.BillboardSystem.registerSystem()
//        RealityKitContent.TrailAnimationSystem.registerSystem()
//    }
//    
//    var body: some SwiftUI.Scene {
//        WindowGroup {
//            DioramaContentView(spaceId: immersiveSpaceIdentifier, viewModel: viewModel)
//        }
//        .windowStyle(.plain)
//        
//        ImmersiveSpace(id: immersiveSpaceIdentifier) {
//            DioramaView(viewModel: viewModel)
//        }
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func applicationShouldTerminateAfterLaseWindowClose(_ sender: UIApplication) -> Bool {
//        return true
//    }
//}
