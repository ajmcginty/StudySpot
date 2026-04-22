import SwiftUI

struct SpotListView: View {
    var viewModel: SpotsViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.spots) { spot in
                // TODO: spot row with name, open/closed badge, noise icon, rating
                Text(spot.name)
            }
            .listStyle(.plain)
            .navigationTitle("Study Spots")
        }
    }
}
