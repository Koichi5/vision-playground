//
//  HomeView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import SwiftUI

struct HomeView: View {
    let appState: AppState
    let modelLoader: ModelLoader
    let immersiveSpaceIdentifier: String
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            VStack (spacing: 20) {
                Text("Object Placement")
                    .font(.title)
                
                InfoLabel(appState: appState)
                    .padding(.horizontal, 30)
                    .frame(width: 400)
                    .fixedSize(horizontal: false, vertical: true)
                
                Group {
                    if !modelLoader.didFinishLoading {
                        VStack(spacing: 10) {
                            Text("Loading models ...")
                            ProgressView(value: modelLoader.progress)
                                .frame(maxWidth: 200)
                        }
                    } else if !appState.immersiveSpaceOpened {
                        Button("Enter") {
                            Task {
                                switch await openImmersiveSpace(id: immersiveSpaceIdentifier) {
                                case .opened:
                                    break
                                case .error:
                                    print("An error occured when trying to open the immersive space \(immersiveSpaceIdentifier)")
                                case .userCancelled:
                                    print("The user declined opening immersive space \(immersiveSpaceIdentifier)")
                                @unknown default:
                                    break
                                }
                            }
                        }
                        .disabled(!appState.canEnterImmersiveSpace)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.vertical, 24)
            .glassBackgroundEffect()
            
            if appState.immersiveSpaceOpened {
                ObjectPlacementMenuView(appState: appState)
                    .padding(20)
                    .glassBackgroundEffect()
            }
        }
        .fixedSize()
        .onChange(of: scenePhase, initial: true) {
            print("HomeView scene phase: \(scenePhase)")
            if scenePhase == .active {
                Task {
                    await appState.queryWorldSensingAuthorization()
                }
            } else {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
        .onChange(of: appState.providersStoppedWithError, { _,
            providersStoppedWithError in
            if providersStoppedWithError {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
                
                appState.providersStoppedWithError = false
            }
        })
        .task {
            if appState.allRequiredProvidersAreSupported {
                await appState.requestWorldSensingAuthorization()
            }
        }
    }
}

#Preview(windowStyle: .plain) {
    HStack {
        VStack {
            HomeView(appState: AppState.previewAppState(),
                     modelLoader: ModelLoader(progress: 0.5),
                     immersiveSpaceIdentifier: "A")
            HomeView(appState: AppState.previewAppState(),
                     modelLoader: ModelLoader(progress: 1.0),
                     immersiveSpaceIdentifier: "A")
        }
        VStack {
            HomeView(appState: AppState.previewAppState(immersiveSpaceOpened: true),
                     modelLoader: ModelLoader(progress: 1.0),
                     immersiveSpaceIdentifier: "A")
        }
    }
}
