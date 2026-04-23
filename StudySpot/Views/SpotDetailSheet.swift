import SwiftUI

struct SpotDetailSheet: View {
    var spot: StudySpot
    @State private var viewModel = SpotDetailViewModel()
    @State private var showReviews = false
    @State private var showAddReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Name + open/closed badge
                HStack(alignment: .top) {
                    Text(spot.name)
                        .font(.title)
                    Spacer()
                    OpenBadge(isOpen: spot.isOpenNow)
                }

                // Hours
                Text(hoursText)
                    .foregroundStyle(.secondary)

                // Photo
                if !spot.imageURL.isEmpty, let url = URL(string: spot.imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay { ProgressView() }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Attribute tags
                AttributeTagRow(spot: spot)

                Divider()

                // Busyness
                HStack {
                    Label(spot.busyness.capitalized, systemImage: busynessIcon)
                        .foregroundStyle(busynessColor)
                    Spacer()
                    // Average rating + review count
                    StarRatingView(rating: spot.averageRating)
                    Text("(\(spot.reviewCount))")
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Action buttons
                Button("See All Reviews") {
                    showReviews = true
                }
                .frame(maxWidth: .infinity)

                Button("I'm Here — Rate This Spot") {
                    showAddReview = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear {
            if let id = spot.id { viewModel.startListening(for: id) }
        }
        .onDisappear { viewModel.stopListening() }
        .sheet(isPresented: $showReviews) {
            NavigationStack {
                ReviewListView(reviews: viewModel.reviews)
                    .navigationTitle("Reviews")
            }
        }
        .sheet(isPresented: $showAddReview) {
            NavigationStack {
                AddReviewView(spot: spot)
            }
        }
    }

    private var hoursText: String {
        if spot.isOpenNow {
            return "Open until \(spot.hoursClose)"
        } else {
            return "Closed · Opens at \(spot.hoursOpen)"
        }
    }

    private var busynessIcon: String {
        switch spot.busyness {
        case "empty":  return "person"
        case "packed": return "person.3.fill"
        default:       return "person.2"
        }
    }

    private var busynessColor: Color {
        switch spot.busyness {
        case "empty":  return .green
        case "packed": return .red
        default:       return .orange
        }
    }
}

// MARK: - Supporting views

struct OpenBadge: View {
    var isOpen: Bool

    var body: some View {
        Text(isOpen ? "Open" : "Closed")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isOpen ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
            .foregroundStyle(isOpen ? .green : .gray)
            .clipShape(Capsule())
    }
}

private struct AttributeTagRow: View {
    var spot: StudySpot

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                AttributeTag(icon: noiseLevelIcon, label: spot.noiseLevel.capitalized)
                if spot.hasOutlets {
                    AttributeTag(icon: "poweroutlet.type.b.fill", label: "Outlets")
                }
                if spot.hasWifi {
                    AttributeTag(icon: "wifi", label: "WiFi")
                }
                if spot.goodForGroups {
                    AttributeTag(icon: "person.3", label: "Groups OK")
                }
            }
        }
    }

    private var noiseLevelIcon: String {
        switch spot.noiseLevel {
        case "quiet": return "speaker.slash"
        case "loud":  return "speaker.3"
        default:      return "speaker.1"
        }
    }
}

private struct AttributeTag: View {
    var icon: String
    var label: String

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}

struct StarRatingView: View {
    var rating: Double
    var maxStars: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxStars, id: \.self) { star in
                Image(systemName: starIcon(for: star))
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
    }

    private func starIcon(for star: Int) -> String {
        if Double(star) <= rating {
            return "star.fill"
        } else if Double(star) - 0.5 <= rating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
