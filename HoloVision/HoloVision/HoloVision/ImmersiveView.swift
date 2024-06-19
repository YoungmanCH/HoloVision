//
// ImmersiveView.swift
// HoloVision
//
// Created by Youngman on 2024/06/18.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
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
               let rifle = rifleModel.children.first?.children.first {
                rifle.scale = [0.01, 0.01, 0.01]
                rifle.position.y = 0.5
                rifle.position.z = -1
                
                rifle.generateCollisionShapes(recursive: false)
                rifle.components.set(InputTargetComponent())
                
                rifle.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
                    massProperties: .default,
                    material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.1),
                    mode: .dynamic
                ))
                
                rifle.components[PhysicsMotionComponent.self] = .init()
                
                content.add(rifle)
            }
        }
        .gesture(dragDesture)
    }

    var dragDesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
            }
            .onEnded { value in
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
            }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
    // .previewLayout(.sizeThatFits)
}
