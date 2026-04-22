import Foundation
import FirebaseFirestore

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var rating: Int = 5
    var comment: String = ""
    var imageURL: String = ""
    var busynessReport: String = "moderate"  // "empty" / "moderate" / "packed"
    var postedBy: String = ""
    var datePosted: Date = Date()
}
