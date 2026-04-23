import Foundation
import FirebaseFirestore
import Observation

enum SpotFilter: String, CaseIterable {
    case all = "All"
    case openNow = "Open Now"
    case quiet = "Quiet"
    case hasOutlets = "Outlets"
}

@Observable
class SpotsViewModel {
    var spots: [StudySpot] = []
    var activeFilter: SpotFilter = .all
    private var listener: ListenerRegistration?

    // Filtered + sorted list used by SpotListView — open spots always float to the top
    var filteredSpots: [StudySpot] {
        let filtered = spots.filter { spot in
            switch activeFilter {
            case .all:        return true
            case .openNow:    return spot.isOpenNow
            case .quiet:      return spot.noiseLevel == "quiet"
            case .hasOutlets: return spot.hasOutlets
            }
        }
        return filtered.sorted { $0.isOpenNow && !$1.isOpenNow }
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
