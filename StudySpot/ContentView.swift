//
//  ContentView.swift
//  StudySpot
//
//  Created by Aidan McGinty on 4/22/26.
//

import SwiftUI

struct ContentView: View {
    // Shared across both tabs — one Firestore listener and one location manager for the whole app
    @State private var spotsViewModel = SpotsViewModel()
    @State private var locationManager = LocationManager()
    @State private var displayName: String = UserDefaults.standard.string(forKey: "displayName") ?? ""

    var body: some View {
        if displayName.isEmpty {
            DisplayNameView(displayName: $displayName)
        } else {
            TabView {
                SpotMapView(viewModel: spotsViewModel, locationManager: locationManager)
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
            // Keep the ViewModel's location in sync so Distance sorting works
            .onChange(of: locationManager.lastLocation) { _, newLocation in
                spotsViewModel.userLocation = newLocation
            }
        }
    }
}
