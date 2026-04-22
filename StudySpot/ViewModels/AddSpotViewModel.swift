import Foundation
import FirebaseFirestore
import SwiftUI
import Observation

@Observable
class AddSpotViewModel {
    var name: String = ""
    var description: String = ""
    var hoursOpen: String = ""
    var hoursClose: String = ""
    var isOpenWeekends: Bool = false
    var noiseLevel: String = "moderate"
    var hasOutlets: Bool = false
    var hasWifi: Bool = false
    var goodForGroups: Bool = false
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var selectedImage: UIImage? = nil
    var postedBy: String = ""

    func autofillLocation(from locationManager: LocationManager) {
        guard let location = locationManager.lastLocation else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }

    func save() async {
        var imageURL = ""
        if let image = selectedImage {
            imageURL = await ImageUploader.upload(image: image) ?? ""
        }

        var spot = StudySpot()
        spot.name = name
        spot.description = description
        spot.latitude = latitude
        spot.longitude = longitude
        spot.imageURL = imageURL
        spot.hoursOpen = hoursOpen
        spot.hoursClose = hoursClose
        spot.isOpenWeekends = isOpenWeekends
        spot.noiseLevel = noiseLevel
        spot.hasOutlets = hasOutlets
        spot.hasWifi = hasWifi
        spot.goodForGroups = goodForGroups
        spot.postedBy = postedBy
        spot.datePosted = Date()

        let db = Firestore.firestore()
        try? await db.collection("studySpots").addDocument(from: spot)
    }
}
