import SwiftUI

struct SpotListView: View {
    @Bindable var viewModel: SpotsViewModel
    @State private var selectedSpot: StudySpot?

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
                    Button {
                        selectedSpot = spot
                    } label: {
                        SpotRow(spot: spot)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Study Spots")
        }
        .sheet(item: $selectedSpot) { spot in
            SpotDetailSheet(spot: spot)
        }
    }
}

private struct SpotRow: View {
    var spot: StudySpot

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Image(systemName: noiseLevelIcon)
                        .foregroundStyle(.secondary)
                    Text(spot.noiseLevel.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                OpenBadge(isOpen: spot.isOpenNow)
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
