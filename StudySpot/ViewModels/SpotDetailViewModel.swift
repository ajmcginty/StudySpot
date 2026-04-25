import Foundation
import FirebaseFirestore
import Observation

@Observable
class SpotDetailViewModel {
    var reviews: [Review] = []
    private var listener: ListenerRegistration?

    func startListening(for spotID: String) {
        let db = Firestore.firestore()
        listener = db.collection("studySpots")
            .document(spotID)
            .collection("reviews")
            .order(by: "datePosted", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    return
                }
                self.reviews = snapshot?.documents.compactMap {
                    try? $0.data(as: Review.self)
                } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
