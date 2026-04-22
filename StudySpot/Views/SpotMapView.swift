import SwiftUI
import MapKit

struct SpotMapView: View {
    var viewModel: SpotsViewModel
    @State private var showAddSpot = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map {
                // TODO: add spot annotations
            }
            .ignoresSafeArea()

            Button {
                showAddSpot = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
        .sheet(isPresented: $showAddSpot) {
            NavigationStack {
                AddSpotView()
            }
        }
    }
}
