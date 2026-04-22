//
//  StudySpotApp.swift
//  StudySpot
//
//  Created by Aidan McGinty on 4/22/26.
//

import SwiftUI
import FirebaseCore

@main
struct StudySpotApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
