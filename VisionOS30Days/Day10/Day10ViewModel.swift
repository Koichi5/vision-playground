import SwiftUI
import RealityKit

@Observable
class Day10ViewModel {

    private let planeSize = CGSize(width: 0.32, height: 0.18)
    private let maxPlaneSize = CGSize(width: 3.0, height: 2.0)

    private var contentEntity = Entity()
    private var boardPlanes: [ModelEntity] = []
    private var images: [MaterialParameters.Texture] = []
    private var sorted = true
    
    // immersive space の content.add(model.setupContentEntity) で使用
    // 返り値が Entity であるため、content.add の引数に使用可能
    func setupContentEntity() -> Entity {
        
        // for 文で 26枚ある画像から TextureResource を読み込み
        // 読み込んだ texture をマテリアルの変数の一つである Texture に渡す
        // そしてそれを MaterialParameters.Texture のリストである images に追加
        for i in 0..<25 {
            let name = "Image\(i)"
            if let texture = try? TextureResource.load(named: name) {
                images.append(MaterialParameters.Texture(texture))
            }
        }

        setup()
        return contentEntity
    }
    
    // 画像がそれぞれ順番に並んでいるかバラバラになっているかを切り替える処理
    func toggleSorted() {
        // もし sorted が true の場合は画像が順番に並んでいるということなので、処理の初めに sorted を false にしてからそれぞれの画像の位置をランダムに変更
        if sorted {
            sorted.toggle()
            randomSetChildPositions()
        } else {
        // もし sorted が false の場合は画像がバラバラになっているということなので、処理の初めに sorted を true にしてからそれぞれの画像の位置をもとにあった位置に戻す
            sorted.toggle()
            resetChildPositions()
        }
    }

    // MARK: - Private

    // setupContentEntity() の中で実行される
    private func setup() {
        
        // 4回平面を生成している
        for i in 0..<3 {
            let boardPlane = ModelEntity(
                mesh: .generatePlane(width: 3, height: 2),
                materials: [SimpleMaterial(color: .clear, isMetallic: false)]
            )
            
            // 生成した平面の位置に関して、 z の値だけを i に応じて増やしていくことで横方向に位置がズレた平面ができる
            boardPlane.position = SIMD3<Float>(x: 0, y: 2, z: -0.5 - 0.1 * Float(i + 1))
            
            // 生成した平面を元の Entity である contentEntity に追加している。
            contentEntity.addChild(boardPlane)
            
            // 生成した平面を boardPlanes にも追加することで、この ViewModel 全体で平面のリストを扱うことができる
            boardPlanes.append(boardPlane)
            
            // 生成した平面を addChildEntities に渡す（後述）
            addChildEntities(boardPlane: boardPlane)
        }
    }
    
    // setup() で生成された平面の ModelEntity を受け取る
    private func addChildEntities(boardPlane: ModelEntity) {

        var i: Int = 0
        
        // images には setupContentEntity 関数でそれぞれの画像を反映した MaterialParameters.Texture が格納されている
        // その images をシャッフルして、prefix(30) で初めの 30個を取得している
        for image in images.shuffled().prefix(30) {
            
            // i を 5 で割った値を divisionResult として定義している
            let divisionResult = i.quotientAndRemainder(dividingBy: 5)
            
            // x に対しては先ほどの i を 5 で割った値の「reminder」つまり「余り」をもとに位置を決定
            let x: Float = Float(divisionResult.remainder) * 0.4 - 0.75
            // y に対しては先ほどの i を 5 で割った値をもとに位置を決定している
            let y: Float = Float(divisionResult.quotient) * 0.25 - 0.5
            // z に関しては平面の z 軸の位置に i をかけている
            let z: Float = boardPlane.position.z + Float(i) * 0.0001

            let entity = makePlane(name: "", posision: SIMD3<Float>(x: x, y: y, z: z), texture: image)
            
            // Add Light
            let environment = try! EnvironmentResource.load(named: "ImageBasedLight")
            entity.components[ImageBasedLightComponent.self] = .init(source: .single(environment), intensityExponent: 1)
            entity.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: entity)

            boardPlane.addChild(entity)

            i += 1
        }
    }

    private func makePlane(name: String, posision: SIMD3<Float>, texture: MaterialParameters.Texture) -> ModelEntity {

        var material = SimpleMaterial()
        material.color = .init(texture: texture)

        let entity = ModelEntity(
            mesh: .generatePlane(width: 0.32, height: 0.18, cornerRadius: 0.0),
            materials: [material],
            collisionShape: .generateBox(width: 0.32, height: 0.18, depth: 0.1),
            mass: 0.0
        )

        entity.name = name
        entity.position = posision
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))

        return entity
    }

    private func move(entity: Entity, position: SIMD2<Float>) {
        let move = FromToByAnimation<Transform>(
            name: "move",
            from: .init(scale: .init(repeating: 1), translation: entity.position),
            to: .init(scale: .init(repeating: 1), translation: .init(x: position.x, y: position.y, z: entity.position.z)),
            duration: 2.0,
            timing: .linear,
            bindTarget: .transform
        )
        let animation = try! AnimationResource.generate(with: move)
        entity.playAnimation(animation, transitionDuration: 2.0)
    }

    private func randomSetChildPositions() {
        let size = CGSize(width: planeSize.width * 1.2, height: planeSize.height * 1.2)
        for boardPlane in boardPlanes {
            let newPoints = randomPoints(count: boardPlane.children.count, size: size)
            for i in 0..<boardPlane.children.count {
                let entity = boardPlane.children[i]
                move(entity: entity, position: newPoints[i])
            }
        }
    }

    private func resetChildPositions() {
        for boardPlane in boardPlanes {
            var i: Int = 0
            for entity in boardPlane.children {
                let divisionResult = i.quotientAndRemainder(dividingBy: 5)
                let x: Float = Float(divisionResult.remainder) * 0.4 - 0.75
                let y: Float = Float(divisionResult.quotient) * 0.25 - 0.5
                move(entity: entity, position: SIMD2<Float>(x, y))
                i += 1
            }
        }
    }

    private func randomPoints(count: Int, size: CGSize) -> [SIMD2<Float>] {
        var ret: [SIMD2<Float>] = []
        while ret.count < count {
            if let point = randomPoint(size: size, positions: ret) {
                ret.append(point)
            }
        }
        return ret
    }

    private func randomPoint(size: CGSize, positions: [SIMD2<Float>]) -> SIMD2<Float>? {
        for _ in 0..<5000 {
            let x = CGFloat.random(in: -maxPlaneSize.width...(maxPlaneSize.width / 2))
            let y = CGFloat.random(in: -maxPlaneSize.height...(maxPlaneSize.height / 2))
            let frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: size.width, height: size.height)

            if positions.isEmpty {
                return SIMD2<Float>(Float(x), Float(y))
            } else {
                var intersects = false
                for position in positions {
                    let f = CGRect(x: CGFloat(position.x), y: CGFloat(position.y), width: size.width, height: size.height)
                    if f.intersects(frame) {
                        intersects = true
                    }
                }
                if !intersects {
                    return SIMD2<Float>(Float(frame.minX), Float(frame.minY))
                }
            }
        }
        return nil
    }
}
