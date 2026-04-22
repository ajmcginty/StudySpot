import UIKit
import FirebaseStorage

struct ImageUploader {
    // Uploads a UIImage to Firebase Storage and returns the download URL string
    static func upload(image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }

        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("spot-images/\(filename).jpg")

        do {
            _ = try await storageRef.putDataAsync(imageData)
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("ImageUploader: upload failed — \(error.localizedDescription)")
            return nil
        }
    }
}
