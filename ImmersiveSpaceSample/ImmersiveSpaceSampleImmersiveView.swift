//
//  ImmersiveSpaceSampleImmersiveView.swift
//  VisionPlayground
//
//  Created by Koichi Kishimoto on 2024/02/01.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveSpaceSampleImmersiveView: View {
    var body: some View {
        RealityView { content in
            // 画像からマテリアルを作成
            guard let resource = try? TextureResource.load(named: "aurora") else {
                // If the asset isn't available, something is wrong with the app.
                fatalError("Unable to load starfield texture.")
            }
            var material = UnlitMaterial()
            material.color = .init(texture: .init(resource))

            // マテリアルを大きな球体に取り付けます。
            let entity = Entity()
            entity.components.set(ModelComponent(
                mesh: .generateSphere(radius: 1000),
                materials: [material]
            ))

            // テクスチャ画像が内側に反映。
            entity.scale *= .init(x: -1, y: 1, z: 1)

            content.add(entity)
        }
    }
}

#Preview {
    ImmersiveSpaceSampleImmersiveView()
}
