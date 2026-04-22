import Foundation
import FirebaseFirestore
import Observation

@Observable
class SpotsViewModel {
    var spots: [StudySpot] = []
    private var listener: ListenerRegistration?

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
