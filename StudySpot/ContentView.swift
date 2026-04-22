//
//  ContentView.swift
//  StudySpot
//
//  Created by Aidan McGinty on 4/22/26.
//

import SwiftUI

struct ContentView: View {
    // Single SpotsViewModel shared across both tabs — one Firestore listener for the whole app
    @State private var spotsViewModel = SpotsViewModel()

    var body: some View {
        TabView {
            SpotMapView(viewModel: spotsViewModel)
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            SpotListView(viewModel: spotsViewModel)
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
        }
        .onAppear { spotsViewModel.startListening() }
        .onDisappear { spotsViewModel.stopListening() }
    }
}
