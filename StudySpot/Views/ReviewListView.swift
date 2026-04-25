import SwiftUI

struct ReviewListView: View {
    var reviews: [Review]

    var body: some View {
        if reviews.isEmpty {
            ContentUnavailableView(
                "No Reviews Yet",
                systemImage: "star.slash",
                description: Text("Be the first to rate this spot!")
            )
        } else {
        List(reviews) { review in
            VStack(alignment: .leading, spacing: 8) {

                HStack {
                    // Star rating
                    StarRatingView(rating: Double(review.rating))
                    Spacer()
                    // Busyness badge
                    Text(review.busynessReport.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }

                if !review.comment.isEmpty {
                    Text(review.comment)
                        .font(.body)
                }

                // Photo thumbnail
                if !review.imageURL.isEmpty, let url = URL(string: review.imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay { ProgressView() }
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack {
                    Text(review.postedBy)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(review.datePosted.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .navigationTitle("Reviews")
        }
    }
}
