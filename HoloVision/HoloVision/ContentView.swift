//
//  ContentView.swift
//  HoloVision
//
//  Created by Youngman on 2024/06/18.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, world!")
            Button("Let's tap.") {
                
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding()
        .overlay(Balls())
    }
}

struct Balls: View {
    @State private var scale = false;
    var body: some View {
        RealityView { content in
            for _ in 1...5 {
                let model = ModelEntity(
                    mesh: .generateSphere(radius: 0.025),
                    materials: [SimpleMaterial(color: .red, isMetallic: true)]
                );
                
                let x = Float.random(in: -0.2...0.2)
                let y = Float.random(in: -0.2...0.2)
                let z = Float.random(in: -0.2...0.2)
                model.position = SIMD3(x, y, z)
                
                model.components.set(InputTargetComponent())
                model.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.025)]))
                content.add(model)
            }
        } update: { content in content.entities.forEach {
            entity in entity.transform.scale = scale ? SIMD3<Float>(2, 2, 2) : SIMD3<Float>(1, 1, 1)
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded() {
            _ in scale.toggle()
        })
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
