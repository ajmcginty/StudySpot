import SwiftUI

struct AddReviewView: View {
    var spot: StudySpot
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddReviewViewModel()

    var body: some View {
        Form {
            // TODO: star rating picker, comment field, busyness picker, photo picker
            Section("Your Review") {
                Stepper("Rating: \(viewModel.rating) stars", value: $viewModel.rating, in: 1...5)
                TextField("Comment (optional)", text: $viewModel.comment)
            }
        }
        .navigationTitle("Rate This Spot")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await viewModel.save(for: spot)
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
