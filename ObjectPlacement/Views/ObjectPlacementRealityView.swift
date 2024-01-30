//
//  ObjectPlacementRealityView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/30.
//

import SwiftUI
import RealityKit

@MainActor
struct ObjectPlacementRealityView: View {
    var appState: AppState
    
    @State private var placementManager = PlacementManager()

    @State private var collisionBeganSubscription: EventSubscription? = nil
    @State private var collisionEndedSubscription: EventSubscription? = nil
    
    private enum Attachments {
        case placementTooltip
        case dragTooltip
        case deleteButton
    }
    
    var body: some View {
        RealityView { content, attachments in
            content.add(placementManager.rootEntity)
            placementManager.appState = appState
            
            if let placementTooltopAttachment = attachments.entity(for: Attachments.placementTooltip) {
                placementManager.addPlacementTooltip(placementTooltopAttachment)
            }
            
            if let dragTooltipAttachment = attachments.entity(for: Attachments.dragTooltip) {
                placementManager.dragTooltip = dragTooltipAttachment
            }
            
            if let deleteButtonAttachment = attachments.entity(for: Attachments.deleteButton) {
                placementManager.deleteButton = deleteButtonAttachment
            }
            
            collisionBeganSubscription = content.subscribe(to: CollisionEvents.Began.self) {  [weak placementManager] event in
                placementManager?.collisionBegan(event)
            }
            
            collisionEndedSubscription = content.subscribe(to: CollisionEvents.Ended.self) {  [weak placementManager] event in
                placementManager?.collisionEnded(event)
            }
            
            Task {
                await placementManager.runARKitSession()
            }
        } update : { update, attachments in
            let placementState = placementManager.placementState
            
            if let placementTooltip = attachments.entity(for: Attachments.placementTooltip) {
                placementTooltip.isEnabled = (placementState.selectedObject != nil && placementState.shouldShowPreview)
            }
            
            if let dragTooltip = attachments.entity(for: Attachments.dragTooltip) {
                dragTooltip.isEnabled = !placementState.userDraggedAnObject
            }
            
            if let selectedObject = placementState.selectedObject {
                selectedObject.isPreviewActive = placementState.isPlacementPossible
            }
        } attachments: {
            Attachment(id: Attachments.placementTooltip) {
                PlacementTooltip(placementState: placementManager.placementState)
            }
            Attachment(id: Attachments.dragTooltip) {
                TooltipView(text: "Drag to reposition.")
            }
            Attachment(id: Attachments.deleteButton) {
                DeleteButton {
                    Task {
                        await placementManager.removeHighlightedObject()
                    }
                }
            }
        }
        .task {
            await placementManager.processWorldAnchorUpdates()
        }
        .task {
            await placementManager.processDeviceAnchorUpdates()
        }
        .task {
            await placementManager.processPlaneDetectionUpdates()
        }
        .task {
            await placementManager.checkIfAnchoredObjectsNeedToBeDetached()
        }
        .task {
            await placementManager.checkIfMovingObjectsCanBeAnchored()
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            if event.entity.components[CollisionComponent.self]?.filter.group == PlaceableObject.previewCollisionGroup {
                placementManager.placeSelectedObject()
            }
        })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch)
            .onChanged { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.updateDrag(value: value)
                }
            }
            .onEnded { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.endDrag()
                }
            }
        )
        .onAppear() {
            print("Entering immersive space.")
            appState.immersiveSpaceOpened(with: placementManager)
        }
        .onDisappear() {
            print("Leaving immersive space.")
            appState.didLeaveImmersiveSpace()
        }
    }
}
