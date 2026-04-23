import Foundation
import FirebaseFirestore
import SwiftUI
import Observation

@Observable
class AddReviewViewModel {
    var rating: Int = 5
    var comment: String = ""
    var busynessReport: String = "moderate"
    var selectedImage: UIImage? = nil
    var postedBy: String = ""

    func save(for spot: StudySpot) async {
        guard let spotID = spot.id else {
            print("AddReviewViewModel: spot has no ID — cannot save review")
            return
        }

        var imageURL = ""
        if let image = selectedImage {
            imageURL = await ImageUploader.upload(image: image) ?? ""
        }

        var review = Review()
        review.rating = rating
        review.comment = comment
        review.imageURL = imageURL
        review.busynessReport = busynessReport
        review.postedBy = postedBy
        review.datePosted = Date()

        let db = Firestore.firestore()
        let spotRef = db.collection("studySpots").document(spotID)

        // NOTE: setData(from:) on an explicit document ref is the async/throws Codable path
        let reviewRef = spotRef.collection("reviews").document()
        try? await reviewRef.setData(from: review)

        // Recalculate average and update parent spot in the same operation
        let newCount = spot.reviewCount + 1
        let newAverage = ((spot.averageRating * Double(spot.reviewCount)) + Double(rating)) / Double(newCount)

        try? await spotRef.updateData([
            "averageRating": newAverage,
            "reviewCount": newCount,
            "busyness": busynessReport
        ])
    }
}
