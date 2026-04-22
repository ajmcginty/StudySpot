import Foundation
import FirebaseFirestore

struct StudySpot: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String = ""
    var description: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var imageURL: String = ""
    var hoursOpen: String = ""       // e.g. "8:00 AM"
    var hoursClose: String = ""      // e.g. "11:00 PM"
    var isOpenWeekends: Bool = false
    var noiseLevel: String = "moderate"  // "quiet" / "moderate" / "loud"
    var busyness: String = "moderate"    // "empty" / "moderate" / "packed"
    var hasOutlets: Bool = false
    var goodForGroups: Bool = false
    var hasWifi: Bool = false
    var averageRating: Double = 0.0
    var reviewCount: Int = 0
    var postedBy: String = ""
    var datePosted: Date = Date()

    // Compares stored open/close strings against the current clock time
    var isOpenNow: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let calendar = Calendar.current

        guard let openTime = formatter.date(from: hoursOpen),
              let closeTime = formatter.date(from: hoursClose) else {
            return false
        }

        let openMinutes = calendar.component(.hour, from: openTime) * 60
                        + calendar.component(.minute, from: openTime)
        let closeMinutes = calendar.component(.hour, from: closeTime) * 60
                         + calendar.component(.minute, from: closeTime)

        let now = Date()
        let nowMinutes = calendar.component(.hour, from: now) * 60
                       + calendar.component(.minute, from: now)

        return nowMinutes >= openMinutes && nowMinutes < closeMinutes
    }
}
