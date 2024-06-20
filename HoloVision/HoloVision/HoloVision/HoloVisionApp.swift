//
//  HoloVisionApp.swift
//  HoloVision
//
//  Created by Youngman on 2024/06/18.
//

import SwiftUI

@Observable
class RifleData {
    var rolledNumber = 0
}

@main
struct HoloVisionApp: App {
    @State var rifleData = RifleData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(rifleData: rifleData)
        }
        .defaultSize(width: 100, height: 100)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(rifleData: rifleData)
        }
    }
}
