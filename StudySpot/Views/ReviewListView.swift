import SwiftUI

struct ReviewListView: View {
    var reviews: [Review]

    var body: some View {
        List(reviews) { review in
            // TODO: stars, comment, photo thumbnail, busyness report, date
            VStack(alignment: .leading) {
                Text("\(review.rating) stars")
                    .font(.title3)
                if !review.comment.isEmpty {
                    Text(review.comment)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Reviews")
    }
}
