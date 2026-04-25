import SwiftUI
import PhotosUI

struct AddReviewView: View {
    var spot: StudySpot
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddReviewViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showSaveError = false

    private let busynessOptions = ["empty", "moderate", "packed"]

    var body: some View {
        Form {
            Section("Rating") {
                // Tappable star row — cleaner than a Stepper for 1–5
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                            .onTapGesture { viewModel.rating = star }
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Comment") {
                TextField("How was it? (optional)", text: $viewModel.comment, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("How Busy?") {
                Picker("Busyness", selection: $viewModel.busynessReport) {
                    ForEach(busynessOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Photo") {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label(
                        viewModel.selectedImage == nil ? "Add Photo" : "Photo Selected",
                        systemImage: "camera"
                    )
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.selectedImage = image
                        }
                    }
                }
            }
        }
        .navigationTitle("Rate This Spot")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.postedBy = UserDefaults.standard.string(forKey: "displayName") ?? ""
                    Task {
                        let success = await viewModel.save(for: spot)
                        if success {
                            dismiss()
                        } else {
                            showSaveError = true
                        }
                    }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .alert("Save Failed", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.saveError ?? "Something went wrong. Please try again.")
        }
    }
}
