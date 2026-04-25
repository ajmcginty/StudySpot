import SwiftUI
import MapKit
import PhotosUI

struct AddSpotView: View {
    var locationManager: LocationManager
    var spots: [StudySpot]

    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddSpotViewModel()

    // Start centered on the user; they scroll/tap to pick the exact spot
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    // DatePicker bindings — stored as Date, formatted to String on save
    @State private var openTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var closeTime: Date = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()

    @State private var selectedPhotoItem: PhotosPickerItem?
    // Set after the spot saves — triggers the review sheet and then dismisses this sheet
    @State private var savedSpot: StudySpot? = nil

    private let noiseOptions = ["quiet", "moderate", "loud"]
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        Form {
            Section("Where is this spot?") {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        if let coord = viewModel.selectedCoordinate {
                            Marker("New Spot", coordinate: coord)
                                .tint(.blue)
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    // NOTE: onTapGesture is a discrete gesture so it doesn't interfere with
                    // MapKit's continuous pan/zoom recognizers
                    .onTapGesture { screenPosition in
                        if let coord = proxy.convert(screenPosition, from: .local) {
                            viewModel.selectedCoordinate = coord
                        }
                    }
                }
                if viewModel.selectedCoordinate == nil {
                    Text("Tap the map to pin this spot")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Warn if similar spots already exist nearby — helps avoid duplicates
            let nearby = viewModel.nearbySpots(in: spots)
            if !nearby.isEmpty {
                Section {
                    ForEach(nearby) { spot in
                        Label(spot.name, systemImage: "mappin.circle")
                    }
                } header: {
                    Text("Nearby spots — is this a duplicate?")
                } footer: {
                    Text("These spots are within 150m of your pin. Make sure you're not adding one that already exists.")
                }
            }

            Section("Spot Info") {
                TextField("Name", text: $viewModel.name)
                TextField("Description", text: $viewModel.description)
            }

            Section("Hours") {
                DatePicker("Opens", selection: $openTime, displayedComponents: .hourAndMinute)
                DatePicker("Closes", selection: $closeTime, displayedComponents: .hourAndMinute)
                Toggle("Open on Weekends", isOn: $viewModel.isOpenWeekends)
            }

            Section("Attributes") {
                Picker("Noise Level", selection: $viewModel.noiseLevel) {
                    ForEach(noiseOptions, id: \.self) { level in
                        Text(level.capitalized).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Has Outlets", isOn: $viewModel.hasOutlets)
                Toggle("Has WiFi", isOn: $viewModel.hasWifi)
                Toggle("Good for Groups", isOn: $viewModel.goodForGroups)
            }

            Section("Photo") {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label(
                        viewModel.selectedImage == nil ? "Choose Photo" : "Photo Selected",
                        systemImage: "photo"
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
        .navigationTitle("Add Spot")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.hoursOpen = timeFormatter.string(from: openTime)
                    viewModel.hoursClose = timeFormatter.string(from: closeTime)
                    viewModel.postedBy = UserDefaults.standard.string(forKey: "displayName") ?? ""
                    Task {
                        if let spotID = await viewModel.save() {
                            // Build a minimal spot so AddReviewView can write to the right subcollection
                            var spot = StudySpot()
                            spot.id = spotID
                            spot.name = viewModel.name
                            savedSpot = spot
                        } else {
                            dismiss()
                        }
                    }
                }
                .disabled(
                    viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ||
                    viewModel.selectedCoordinate == nil
                )
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        // After the spot is saved, immediately prompt for a review.
        // onDisappear closes AddSpotView whether the user saves or cancels the review.
        .sheet(item: $savedSpot) { spot in
            NavigationStack {
                AddReviewView(spot: spot)
            }
            .onDisappear {
                dismiss()
            }
        }
        .alert("Save Failed", isPresented: Binding(
            get: { viewModel.saveError != nil },
            set: { if !$0 { viewModel.saveError = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.saveError = nil }
        } message: {
            Text(viewModel.saveError ?? "")
        }
    }
}
