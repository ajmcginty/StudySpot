import SwiftUI
import MapKit

struct SpotMapView: View {
    var viewModel: SpotsViewModel
    var locationManager: LocationManager

    @State private var selectedSpot: StudySpot?
    @State private var showAddSpot = false
    @State private var position: MapCameraPosition = .automatic

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
            .onAppear {
                // Center on user's location if available; otherwise MapKit picks a default
                if let location = locationManager.lastLocation {
                    position = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        latitudinalMeters: 1500,
                        longitudinalMeters: 1500
                    ))
                }
            }

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
                AddSpotView(locationManager: locationManager)
            }
        }
    }
}
