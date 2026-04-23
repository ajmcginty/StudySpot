import SwiftUI

struct SpotListView: View {
    @Bindable var viewModel: SpotsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter picker
                Picker("Filter", selection: $viewModel.activeFilter) {
                    ForEach(SpotFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List(viewModel.filteredSpots) { spot in
                    NavigationLink(destination: SpotDetailSheet(spot: spot)) {
                        SpotRow(spot: spot)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Study Spots")
        }
    }
}

private struct SpotRow: View {
    var spot: StudySpot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(spot.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                OpenBadge(isOpen: spot.isOpenNow)
            }

            HStack(spacing: 6) {
                Image(systemName: noiseLevelIcon)
                    .foregroundStyle(.secondary)
                Text(spot.noiseLevel.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                StarRatingView(rating: spot.averageRating)
            }
        }
        .padding(.vertical, 4)
    }

    private var noiseLevelIcon: String {
        switch spot.noiseLevel {
        case "quiet": return "speaker.slash"
        case "loud":  return "speaker.3"
        default:      return "speaker.1"
        }
    }
}

// NOTE: OpenBadge and StarRatingView are defined in SpotDetailSheet.swift
// They are internal (no access modifier) so they are visible across the module
