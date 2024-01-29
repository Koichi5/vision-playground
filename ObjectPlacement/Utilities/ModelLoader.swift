//
//  ModelLoader.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import Foundation
import RealityKit

// MainActor を追加することでこの関数は常にメインスレッドで実行される
// メインスレッド外でこの関数を呼び出す場合は非同期処理にする必要がある
@MainActor
@Observable
final class ModeLoader {
    private var didStartLoading = false
    private(set) var progress: Float = 0.0
    private(set) var placeableObjects = [PlaceableObject]()
    private var fileCount: Int = 0
    private var filesLoaded: Int = 0
    
    init(progress: Float? = nil) {
        if let progress {
            self.progress = progress
        }
    }
    
    var didFinishLoading: Bool {progress >= 1.0}
    
    // ファイルのローディングのアップデート
    private func updateProgress() {
        filesLoaded += 1
        if fileCount == 0 {
            // ファイルのカウントが０であれば進捗も０
            progress = 0.0
        } else if filesLoaded == fileCount {
            // ロードされたファイルの数が元々のファイルの数と同じであれば進捗は１
            progress = 1.0
        } else {
            // 完了していない場合はローディングされていないファイルの割合を表示
            progress = Float(filesLoaded) / Float(fileCount)
        }
    }
    
    func loadObjects() async {
        guard !didStartLoading else {return}
        didStartLoading.toggle()
        
        var usdzFiles: [String] = []
        if let resourcesPath = Bundle.main.resourcePath {
            try? usdzFiles = FileManager.default.contentsOfDirectory(atPath: resourcesPath).filter {$0.hasSuffix(".usdz")}
        }
        
        assert(!usdzFiles.isEmpty, "Add USDZ files to the '3DModels' group of this project.")
        
        fileCount = usdzFiles.count
        await withTaskGroup(of: (Void.self)) { group in
            for usdz in usdzFiles {
                let fileName = URL(string: usdz)!.deletingPathExtension().lastPathComponent
                group.addTask {
                    await self.loadObject(fileName)
                    await self.updateProgress()
                }
            }
        }
    }
    
    func loadObject(_ fileName: String) async {
        var modelEntity: ModelEntity
        var previewEntity: Entity
        do {
            try await modelEntity = ModelEntity(named: fileName)
            try await previewEntity = Entity(named: fileName)
            previewEntity.name = "Preview of \(modelEntity.name)"
        } catch {
            fatalError("Failed to load model \(fileName)")
        }
        
        do {
            let shape = try await ShapeResource.generateConvex(from: modelEntity.model!.mesh)
            // オブジェクトの衝突に関して、衝突できる要素をフィルターで選択
            previewEntity.components.set(CollisionComponent(shapes: [shape], isStatic: false, filter: CollisionFilter(group: PlaceableObject.previewCollisionGroup, mask: .all)))
            
            let previewInput = InputTargetComponent(allowedInputTypes: [.indirect])
            previewEntity.components[InputTargetComponent.self] = previewInput
        } catch {
            fatalError("Failed to generate shape resource for model \(fileName)")
        }
        
        let descriptor = ModelDescriptor(fileName: fileName, displayName: modelEntity.displayName)
        placeableObjects.append(PlaceableObject(descriptor: descriptor, renderContent: modelEntity, previewEntity: previewEntity))
    }
}

fileprivate extension ModelEntity {
    var displayName: String? {
        // モデルの表示名をスネークケースから通常の空白を用いたものに変更
        !name.isEmpty ? name.replacingOccurrences(of: "_", with: " ") : nil
    }
}
