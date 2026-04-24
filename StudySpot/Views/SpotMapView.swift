import SwiftUI
import MapKit

struct SpotMapView: View {
    var viewModel: SpotsViewModel
    var locationManager: LocationManager

    @State private var selectedSpot: StudySpot?
    @State private var showAddSpot = false
    // userLocation(fallback:) lets MapKit zoom to the user as soon as the first fix arrives,
    // avoiding the race condition where .automatic renders as the whole world on cold start
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.3355, longitude: -71.1685),
            latitudinalMeters: 1500,
            longitudinalMeters: 1500
        ))
    )

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                UserAnnotation()

                ForEach(viewModel.spots) { spot in
                    Annotation(spot.name, coordinate: CLLocationCoordinate2D(
                        latitude: spot.latitude,
                        longitude: spot.longitude
                    )) {
                        Button {
                            selectedSpot = spot
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(spot.isOpenNow ? .green : .gray)
                        }
                    }
                }
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
        .sheet(item: $selectedSpot) { spot in
            SpotDetailSheet(spot: spot)
        }
        .sheet(isPresented: $showAddSpot) {
            NavigationStack {
                AddSpotView(locationManager: locationManager, spots: viewModel.spots)
            }
        }
    }
}
