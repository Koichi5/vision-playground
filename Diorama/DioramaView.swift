//
//  DioramaView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/07.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DioramaView: View {
    @Environment(\.dismiss) private var dismiss
    
    var viewModel: DioramaViewModel
    
    static let markersQuery = EntityQuery(where: .has(PointOfInterestComponent.self))
    static let runtimeQuery = EntityQuery(where: .has(PointOfInterestRuntimeComponent.self))
    
    @State private var subscriptions = [EventSubscription]()
    @State private var attachmentsProvider = AttachmentsProvider()
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        RealityView { content, _ in
            do {
                let entity = try await Entity(named: "DioramaAssembled", in: RealityKitContent.realityKitContentBundle)
                viewModel.rootEntity = entity
                content.add(entity)
                viewModel.updateScale()
                
                entity.position = SIMD3<Float>(0, 0, -2)
                
                setupBirds(rootEntity: entity)
                
                subscriptions.append(content.subscribe(
                    to: ComponentEvents.DidAdd.self,
                    componentType: PointOfInterestComponent.self, { event in
                        createLearnMoreView(for: event.entity)
                    }))
                
                subscriptions.append(content.subscribe(
                    to: ComponentEvents.DidAdd.self,
                    componentType: TrailComponent.self, { event in
                        let trail = event.entity
                        if let parentRegion = trail.parent?.components[PointOfInterestComponent.self] {
                            trail.components.set(RegionSpecificComponent(region: parentRegion.region))
                        }
                        
                        trail.components.set(ControlledOpacityComponent(shouldShow: false))
                        trail.components.set(OpacityComponent(opacity: 0.0))
                        viewModel.updateRegionSpecificOpacity()
                    }))
            } catch {
                print("Error in RealityView's make: \(error)")
            }
        } update: { content, attachments in
            viewModel.setupAudio()
            
            viewModel.rootEntity?.scene?.performQuery(Self.runtimeQuery).forEach {
                entity in
                guard let component = entity.components[PointOfInterestRuntimeComponent.self] else {
                    return
                }
                
                guard let attachmentEntity = attachments.entity(for: component.attachmentTag) else {return}
                
                guard attachmentEntity.parent == nil else { return }
                
                if let pointOfInterestComponent = entity.components[PointOfInterestComponent.self] {
                    attachmentEntity.components.set(RegionSpecificComponent(region: pointOfInterestComponent.region))
                    attachmentEntity.components.set(OpacityComponent(opacity: 0))
                }
                
                attachmentEntity.components.set(BillboardComponent())
                
                entity.addChild(attachmentEntity)
                attachmentEntity.setPosition([0.0, 0.4, 0.0], relativeTo: entity)
            }
            
            viewModel.updateRegionSpecificOpacity()
            viewModel.updateTerrainMaterial()
        } attachments: {
            ForEach(attachmentsProvider.sortedTagViewPairs, id: \.tag) { pair in
                Attachment(id: pair.tag) {
                    pair.view
                }
            }
        }
    }
    
    private func createLearnMoreView(for entity: Entity) {
        guard entity.components[PointOfInterestComponent.self] == nil else { return }
        
        guard let pointOfInterest = entity.components[PointOfInterestComponent.self] else { return }
        
        let trailEntity: Entity? = entity.children.first(where: {
            $0.hasMaterialParameter(named: TrailAnimationSystem.materialParameterName)
        })
        
        let tag: ObjectIdentifier = entity.id
        
        let view = LearnMoreView(
            name: pointOfInterest.name,
            description: pointOfInterest.description ?? "",
            imageNames: pointOfInterest.imageNames,
            trial: trailEntity,
            viewModel: viewModel
        )
            .tag(tag)
        
        entity.components[PointOfInterestRuntimeComponent.self] = PointOfInterestRuntimeComponent(attachmentTag: tag)
        
        attachmentsProvider.attachments[tag] = AnyView(view)
    }
    
    private func setupBirds(rootEntity entity: Entity) {
        guard let birds = entity.findEntity(named: "Birds") else  { return }
        for bird in birds.children {
            bird.components[FlockingComponent.self] = FlockingComponent()
            
            guard let animationResource = bird.availableAnimations.first else { continue }
            let controller = bird.playAnimation(animationResource.repeat())
            controller.speed = Float.random(in: 1..<2.5)
        }
    }
}

#Preview {
    DioramaView(viewModel: DioramaViewModel())
        .previewLayout(.sizeThatFits)
}
