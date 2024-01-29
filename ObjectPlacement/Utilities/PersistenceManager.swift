//
//  PersistenceManager.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/01/28.
//

import Foundation
import ARKit
import RealityKit

class PersistenceManager {
    private var worldTracking: WorldTrackingProvider
    // 各オブジェクトに付与された world anchor UUID の map
    private var anchoredObjects: [UUID: PlacedObject] = [:]
    
    private var objectsBeingAnchored: [UUID: PlacedObject] = [:]
    
    // どの world anchor にもつけられていないオブジェクトのリスト
    private var movingObjects: [PlacedObject] = []
    
    private let objectAtRestThreshold: Float = 0.001 // 1cm
    // アンカーのアップデートに基づいて取得された、現在の world anchor のリスト
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    
    // 配置されたオブジェクトの world anchor を保存するためのJSONファイル
    static let objectsDatabaseFileName = "persistentObjects.json"
    
    // persistent world anchor に応じてロードされる3Dモデルのファイル
    private var persistedObjectFileNamePerAnchor: [UUID: String] = [:]
    
    var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    
    private var rootEntity: Entity
    
    init(worldTracking: WorldTrackingProvider, rootEntity: Entity) {
        self.worldTracking = worldTracking
        self.rootEntity = rootEntity
    }
    
    // オブジェクトを含むJSONの解読
    func loadPersistedObjects() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = documentsDirectory.first?.appendingPathComponent(PersistenceManager.objectsDatabaseFileName)
        
        guard let filePath, FileManager.default.fileExists(atPath: filePath.path(percentEncoded: true)) else {
            print("Couldn't find file: '\(PersistenceManager.objectsDatabaseFileName)' - skipping deserialication of persistent objects.")
            return
        }
        
        // persistedObject は world anchor に基づいている && restore ということは、仮に App が再起動されたときでも world anchor をもとに、今まであった場所に配置を再現するためのシステム？
        do {
            let data = try Data(contentsOf: filePath)
            persistedObjectFileNamePerAnchor = try JSONDecoder().decode([UUID: String].self, from: data)
        } catch {
            print("Failed to restore the mapping from world anchors to persisted objects")
        }
    }
    
    func saveWorldAnchorsObjectsMapToDisk() {
        var worldAnchorsToFileNames: [UUID: String] = [:]
        for (anchorID, object) in anchoredObjects {
            worldAnchorsToFileNames[anchorID] = object.fileName
        }
        
        let encoder = JSONEncoder()
        do {
            let jsonString = try encoder.encode(worldAnchorsToFileNames)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsDirectory.appendingPathComponent(PersistenceManager.objectsDatabaseFileName)
            
            do {
                try jsonString.write(to: filePath)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func attachPersistedObjectToAnchor(_ modelFileName: String, anchor: WorldAnchor) {
        guard let placeableObject = placeableObjectsByFileName[modelFileName] else {
            print("No object available for '\(modelFileName)' - it will be ignored.")
            return
        }
        
        let object = placeableObject.materialize()
        object.position = anchor.originFromAnchorTransform.translation
        object.orientation = anchor.originFromAnchorTransform.rotation
        object.isEnabled = anchor.isTracked
        rootEntity.addChild(object)
        
        anchoredObjects[anchor.id] = object
    }
    
    @MainActor
    func process(_ anchorUpdate: AnchorUpdate<WorldAnchor>) {
        let anchor = anchorUpdate.anchor
        
        if anchorUpdate.event != .removed {
            // anchor が update されたとき、もしその update が削除でなければ、そのIDのアンカーを更新
            worldAnchors[anchor.id] = anchor
        } else {
            // anchor が update されたとき、もしその update が削除である場合は、現在配置されている anchor を保持している大元の worldAnchors から削除することで、アンカーが削除される
            worldAnchors.removeValue(forKey: anchor.id)
        }
        
        switch anchorUpdate.event {
        case .added:
            if let persistedObjectFileName = persistedObjectFileNamePerAnchor[anchor.id] {
                attachPersistedObjectToAnchor(persistedObjectFileName, anchor: anchor)
            } else if let objectBeingAnchored = objectsBeingAnchored[anchor.id] {
                objectsBeingAnchored.removeValue(forKey: anchor.id)
                anchoredObjects[anchor.id] = objectBeingAnchored
                
                // この時点で anchor は正常に追加され、表示される
                // rootEntity の変更のみを関ししておけば、オブジェクトに対する変更があった場合に反映される
                rootEntity.addChild(objectBeingAnchored)
            } else {
                if anchoredObjects[anchor.id] == nil {
                    Task {
                        print("No object is attached to anchor \(anchor.id) - it can be deleted.")
                        await removeAnchorWithID(anchor.id)
                    }
                }
            }
            fallthrough
        case .updated:
            let object = anchoredObjects[anchor.id]
            object?.position = anchor.originFromAnchorTransform.translation
            object?.orientation = anchor.originFromAnchorTransform.rotation
            object?.isEnabled = anchor.isTracked
        case .removed:
            let object = anchoredObjects[anchor.id]
            object?.removeFromParent()
            anchoredObjects.removeValue(forKey: anchor.id)
        }
    }
    
    @MainActor
    func removeAllPlacedObjects() async {
        await deleteWorldAnchorsForAnchoredObjects()
    }
    
    private func deleteWorldAnchorsForAnchoredObjects() async {
        for anchorID in anchoredObjects.keys {
            await removeAnchorWithID(anchorID)
        }
    }
    
    func removeAnchorWithID(_ uuid: UUID) async {
        do {
            // ここでは anchoredObjects から削除するのではなく、world tracking を管理している部分から anchor を削除する形で行う
            try await worldTracking.removeAnchor(forID: uuid)
        } catch {
            print("Failed to delete world anchor \(uuid) with error \(error)")
        }
    }
    
    @MainActor
    func attachObjectToWorldAnchor(_ object: PlacedObject) async {
        let anchor = WorldAnchor(originFromAnchorTransform: object.transformMatrix(relativeTo: nil))
        movingObjects.removeAll(where: { $0 === object })
        objectsBeingAnchored[anchor.id] = object
        do {
            try await worldTracking.addAnchor(anchor)
        } catch {
            if let worldTrackingError = error as? WorldTrackingProvider.Error, worldTrackingError.code == .worldAnchorLimitReached {
                print(
                """
                Unable to place object "\(object.name)". You’ve placed the maximum number of objects.
                Remove old objects before placing new ones.
                """
                )
            } else {
                print("Failed to add world anchor \(anchor.id) with error: \(error)")
            }
            
            objectsBeingAnchored.removeValue(forKey: anchor.id)
            object.removeFromParent()
            return
        }
    }
    
    @MainActor
    private func detachObjectFromWorldAnchor(_ object: PlacedObject) {
        guard let anchorID = anchoredObjects.first(where: { $0.value === object })?.key else {
            return
        }
        
        // detach された後にする削除される？
        // まずは、現在アンカーされているオブジェクトのリストである anchoredObjects から削除する
        anchoredObjects.removeValue(forKey: anchorID)
        Task {
            // 次に非同期処理で同様の anchorID を持つオブジェクトを worldTracking から削除する（関数の名前の通り）
            await removeAnchorWithID(anchorID)
        }
    }
    
    @MainActor
    func placedObject(for entity: Entity) -> PlacedObject? {
        return anchoredObjects.first(where: {$0.value === entity})?.value
    }
    
    @MainActor
    func object(for entity: Entity) -> PlacedObject? {
        if let placedObject = placedObject(for: entity) {
            return placedObject
        }
        if let movingObject = movingObjects.first(where: {$0 === entity}) {
            return movingObject
        }
        if let anchoringObject = objectsBeingAnchored.first(where: {$0.value === entity})?.value {
            return anchoringObject
        }
        return nil
    }
    
    @MainActor
    func removeObject(_ object: PlacedObject) async {
        guard let anchorID = anchoredObjects.first(where: { $0.value === object })?.key else {
            return
        }
        await removeAnchorWithID(anchorID)
    }
    
    @MainActor
    func checkIfAnchoredObjectsNeedToBeDetached() async {
        let anchoredObjectsBeforeCheck = anchoredObjects
        
        // anchored objects のうち、動かされようとしているもの、world anchore から detach される必要があるものを探す
        for (anchorID, object) in anchoredObjectsBeforeCheck {
            guard let anchor = worldAnchors[anchorID] else {
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                movingObjects.append(object)
                anchoredObjects.removeValue(forKey: anchorID)
                continue
            }
            
            // 現在の anchor の位置と前に登録されていた anchor の位置の誤差を計算
            let distanceToAnchor = object.position(relativeTo: nil) - anchor.originFromAnchorTransform.translation
            
            // 現在の anchor と 前に登録されていた anchor の位置の誤差が基準値（この場合は1cm）より大きければ、movingObjects に登録
            if length(distanceToAnchor) >= objectAtRestThreshold {
                object.atRest = false
                
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                movingObjects.append(object)
                detachObjectFromWorldAnchor(object)
            }
        }
    }
    
    @MainActor
    func checkIfMovingObjectsCanBeAnchored() async {
        let movingObjectsBeforeCheck = movingObjects
        
        for object in movingObjectsBeforeCheck {
            guard !object.isBeingDragged else {continue}
            guard let lastPosition = object.positionAtLastReanchoringCheck else {
                object.positionAtLastReanchoringCheck = object.position(relativeTo: nil)
                continue
            }
            
            let currentPosition = object.position(relativeTo: nil)
            let movementSinceLastCheck = currentPosition - lastPosition
            object.positionAtLastReanchoringCheck = currentPosition
            
            if length(movementSinceLastCheck) < objectAtRestThreshold {
                object.atRest = false
                await attachObjectToWorldAnchor(object)
            }
        }
    }
}
