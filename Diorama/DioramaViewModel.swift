//
//  DioramaViewModel.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/03.
//

import Foundation
import RealityKit
import RealityKitContent
import Observation

@Observable
final class DioramaViewModel {
    let materialParameterName = "Progress"
    
    var rootEntity: Entity? = nil
    var showImmersiveContent: Bool = false
    var sliderValue: Float = 0.0
    var contentScaleSliderValue: Float = 0.5
    
    init(rootEntity: Entity? = nil, showImmersiveContent: Bool = false) {
        self.rootEntity = rootEntity
        self.showImmersiveContent = showImmersiveContent
        updateRegionSpecificOpacity()
    }
    
    static let query = EntityQuery(where: .has(RegionSpecificComponent.self))
    static let audioQuery = EntityQuery(where: .has(RegionSpecificComponent.self) && .has(AmbientAudioComponent.self))
    
    func updateScale() {
        let newScale = Float.lerp(a: 0.2, b: 1.0, t: contentScaleSliderValue)
        rootEntity?.setScale(SIMD3<Float>(repeating: newScale), relativeTo: nil)
    }
    
    func updateRegionSpecificOpacity() {
        rootEntity?.scene?.performQuery(Self.query).forEach({
            regionSpecificEntity in
            guard let component = regionSpecificEntity.components[RegionSpecificComponent.self] else { return }
            
            let opacity: Float = component.region.opacity(forSlideerValue: sliderValue)
            
            if let controlledOpacityComponent = regionSpecificEntity.components[ControlledOpacityComponent.self] {
                let newOpacity = controlledOpacityComponent.opacity(forSliderValue: opacity)
                regionSpecificEntity.components.set(OpacityComponent(opacity: newOpacity))
            } else {
                regionSpecificEntity.components.set(OpacityComponent(opacity: opacity))
            }
        })
        
        rootEntity?.scene?.performQuery(Self.audioQuery).forEach({ audioEmitter in
            guard var audioComponent = audioEmitter.components[AmbientAudioComponent.self],
                  let regionComponent = audioEmitter.components[RegionSpecificComponent.self]
            else { return }
            
            let gain = regionComponent.region.gain(forSliderValue: sliderValue)
            audioComponent.gain = gain
            audioEmitter.components.set(audioComponent)
        })
    }
    
    private var audioControllers = [Region: AudioPlaybackController]()
    private var hasSetUpAudio: Bool {
        Region.allCases.allSatisfy{ region in
            audioControllers[region] != nil
        }
    }
    
    @MainActor
    func setupAudio() {
        Task {
            guard !hasSetUpAudio, let scene = rootEntity?.scene else { return }
            scene.performQuery(Self.audioQuery).forEach({ audioEmitter in
                guard let regionComponent = audioEmitter.components[RegionSpecificComponent.self] else { return }
                
                let primPath: String
                
                switch regionComponent.region {
                case .catalina:
                    primPath = "/Root/Ocean_Sounds_wav"
                case .yosemite:
                    primPath = "/Root/Forest_Sounds_wav"
                }
                
                guard let resource = try? AudioFileResource.load(
                    named: primPath,
                    from: "DioramaAssembled.usda",
                    in: RealityKitContent.RealityKitContentBundle) else { return }
                let audioPlaybackController = audioEmitter.prepareAudio(resource)
                
                audioPlaybackController.play()
                audioControllers[regionComponent.region] = audioPlaybackController
            })
        }
    }
    
    var terrainMaterialValue: Float? {
        guard case .float(let value) = terrainMaterial?.getParameter(name: materialParameterName) else {return nil}
        return value
    }
    
    private var terrainMaterial: ShaderGraphMaterial? {
        rootEntity?.terrain?.shaderGraphMaterial
    }
    
    func resetAudio() {
        audioControllers = [Region: AudioPlaybackController]()
    }
    
    func updateTerrainMaterial() {
        guard let terrain = rootEntity?.terrain,
              let terrainMaterial = terrainMaterial else { return }
        
        do {
            var material = terrainMaterial
            try material.setParameter(name: materialParameterName, value: .float(sliderValue))
            
            if var component = terrain.modelComponent {
                component.materials = [material]
                terrain.components.set(component)
            }
            
            try terrain.update(shaderGraphMaterial: terrainMaterial, { material in
                try material.setParameter(name: materialParameterName, value: .float(sliderValue))
            })
        } catch {
            print("problem: \(error)")
        }
    }
}

fileprivate extension Entity {
    var terrain: Entity? {
        findEntity(named: "FlatTerrain")
    }
}
