//
// ImmersiveView.swift
// HoloVision
//
// Created by Youngman on 2024/06/18.
//

import SwiftUI
import RealityKit
import RealityKitContent

let rifleMap = [
//  + | -
    [1, 6],
    [4, 3],
    [2, 5],
]

struct ImmersiveView: View {
    var rifleData: RifleData
    @State var droppedRifle = false;
    
    var body: some View {
        RealityView { content in
            let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
                floor.generateCollisionShapes(recursive: false)
                floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
            )

            content.add(floor)
            
            if let rifleModel = try? await Entity(named: "M91_rifle"),
               let rifle = rifleModel.children.first?.children.first,
               let environment = try? await EnvironmentResource(named: "whiteStudio")
            {
                rifle.scale = [0.01, 0.01, 0.01]
                rifle.position.y = 0.5
                rifle.position.z = -1
                
                rifle.generateCollisionShapes(recursive: true)
                let collisionShape = ShapeResource.generateSphere(radius: 0.1)

                rifle.components.set([
                    CollisionComponent(shapes: [collisionShape]),
                    InputTargetComponent()
                ])
                
                rifle.components.set(ImageBasedLightComponent(source: .single(environment)))
                rifle.components.set(ImageBasedLightReceiverComponent(imageBasedLight: rifle))
                rifle.components.set(GroundingShadowComponent(castsShadow: true))
                
                rifle.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
                    massProperties: .default,
                    material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.1),
                    mode: .dynamic
                ))
                
                rifle.components[PhysicsMotionComponent.self] = .init()
                                
                content.add(rifle)
                
                let _ = content.subscribe(to: SceneEvents.Update.self) { event in
                    guard droppedRifle else { return }
                    guard let rifleMotion = rifle.components[PhysicsMotionComponent.self] else { return }
                    
                    if simd_length(rifleMotion.linearVelocity) < 0.1 && simd_length(rifleMotion.angularVelocity) < 0.1 {
                        let xDirection = rifle.convert(direction: SIMD3(x: 1, y: 0, z: 0), to: nil)
                        let yDirection = rifle.convert(direction: SIMD3(x: 0, y: 1, z: 0), to: nil)
                        let zDirection = rifle.convert(direction: SIMD3(x: 0, y: 0, z: 1), to: nil)
                        
                        let greatestDirection = [
                            0: xDirection.y,
                            1: yDirection.y,
                            2: zDirection.y,
                        ]
                            .sorted(by: { abs($0.1) > abs($1.1) })[0]
                        
                        rifleData.rolledNumber = rifleMap[greatestDirection.key][greatestDirection.value > 0 ? 0 : 1]
                    }
                }
            }
        }
        .gesture(dragGesture)
    }

    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
            }
            .onEnded { value in
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                
                if !droppedRifle {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in droppedRifle = true
                    }
                }
            }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(rifleData: RifleData())
}


// 落下させるなら、generateBoxを使うと良い。なんかよくわかりません。かなり調べる必要があると思う。
//                let collisionShapeOfSize = ShapeResource.generateBox(size: [0.01, 0.11, 0.01])])
