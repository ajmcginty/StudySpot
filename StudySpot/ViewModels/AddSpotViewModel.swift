import Foundation
import FirebaseFirestore
import SwiftUI
import CoreLocation
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
    var selectedCoordinate: CLLocationCoordinate2D? = nil
    var selectedImage: UIImage? = nil
    var postedBy: String = ""

    // Returns existing spots within 150m of the placed pin
    func nearbySpots(in spots: [StudySpot]) -> [StudySpot] {
        guard let coord = selectedCoordinate else { return [] }
        let pinLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        return spots.filter { spot in
            let spotLocation = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
            return spotLocation.distance(from: pinLocation) <= 150
        }
    }

    // Returns the new spot's Firestore document ID so the caller can immediately prompt for a review
    func save() async -> String? {
        guard let coord = selectedCoordinate else { return nil }

        var imageURL = ""
        if let image = selectedImage {
            imageURL = await ImageUploader.upload(image: image) ?? ""
        }

        var spot = StudySpot()
        spot.name = name
        spot.description = description
        spot.latitude = coord.latitude
        spot.longitude = coord.longitude
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

        // NOTE: setData(from:) on an explicit document ref is the async/throws Codable path;
        // addDocument(from:) is synchronous so can't be used with try? await
        let db = Firestore.firestore()
        let ref = db.collection("studySpots").document()
        try? await ref.setData(from: spot)
        return ref.documentID
    }
}
