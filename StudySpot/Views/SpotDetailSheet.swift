import SwiftUI

struct SpotDetailSheet: View {
    var spot: StudySpot
    @State private var viewModel = SpotDetailViewModel()
    @State private var showReviews = false
    @State private var showAddReview = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TODO: name, open/closed badge, hours, AsyncImage, attribute tags,
            //       busyness indicator, average rating, "See All Reviews", "I'm Here" button
            Text(spot.name)
                .font(.title)
        }
        .padding()
        .onAppear {
            if let id = spot.id { viewModel.startListening(for: id) }
        }
        .onDisappear { viewModel.stopListening() }
        .sheet(isPresented: $showReviews) {
            NavigationStack {
                ReviewListView(reviews: viewModel.reviews)
            }
        }
        .sheet(isPresented: $showAddReview) {
            NavigationStack {
                AddReviewView(spot: spot)
            }
        }
    }
}
