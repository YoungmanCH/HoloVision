//
//  HoloVisionApp.swift
//  HoloVision
//
//  Created by Youngman on 2024/06/18.
//

import SwiftUI

@main
struct HoloVisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 100, height: 100)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
