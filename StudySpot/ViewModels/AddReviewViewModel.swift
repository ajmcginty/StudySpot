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
    var saveError: String? = nil

    func save(for spot: StudySpot) async -> Bool {
        guard let spotID = spot.id else { return false }

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
        // try? returns nil on failure so we can detect and surface the error without do/catch
        let reviewRef = spotRef.collection("reviews").document()
        if (try? await reviewRef.setData(from: review)) == nil {
            saveError = "Couldn't save your review. Please try again."
            return false
        }

        // Recalculate average and update parent spot in the same operation
        let newCount = spot.reviewCount + 1
        let newAverage = ((spot.averageRating * Double(spot.reviewCount)) + Double(rating)) / Double(newCount)

        if (try? await spotRef.updateData([
            "averageRating": newAverage,
            "reviewCount": newCount,
            "busyness": busynessReport
        ])) == nil {
            saveError = "Review saved, but rating couldn't update. Please try again."
            return false
        }

        return true
    }
}
