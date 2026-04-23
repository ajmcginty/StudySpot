import Foundation
import FirebaseFirestore
import CoreLocation
import Observation

enum SpotFilter: String, CaseIterable {
    case all = "All"
    case openNow = "Open Now"
    case distance = "Distance"
}

@Observable
class SpotsViewModel {
    var spots: [StudySpot] = []
    var activeFilter: SpotFilter = .all
    // Updated by ContentView whenever LocationManager gets a new fix
    var userLocation: CLLocation?
    private var listener: ListenerRegistration?

    // Filtered + sorted list used by SpotListView
    var filteredSpots: [StudySpot] {
        let filtered = spots.filter { spot in
            switch activeFilter {
            case .all:      return true
            case .openNow:  return spot.isOpenNow
            case .distance: return true  // show all, just sorted differently below
            }
        }

        switch activeFilter {
        case .distance:
            // Sort nearest-first; spots with unknown distance go to the end
            guard let userLocation else { return filtered }
            return filtered.sorted {
                let a = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                let b = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                return userLocation.distance(from: a) < userLocation.distance(from: b)
            }
        default:
            // Open spots float to the top for All and Open Now
            return filtered.sorted { $0.isOpenNow && !$1.isOpenNow }
        }
    }

    func startListening() {
        let db = Firestore.firestore()
        // Real-time listener — updates spots array whenever Firestore changes
        listener = db.collection("studySpots")
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("SpotsViewModel: error listening to studySpots — \(error.localizedDescription)")
                    return
                }
                self.spots = snapshot?.documents.compactMap {
                    try? $0.data(as: StudySpot.self)
                } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
