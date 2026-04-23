import SwiftUI
import PhotosUI

struct AddSpotView: View {
    var locationManager: LocationManager

    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddSpotViewModel()

    // DatePicker bindings — stored as Date, formatted to String on save
    @State private var openTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var closeTime: Date = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()

    @State private var selectedPhotoItem: PhotosPickerItem?

    private let noiseOptions = ["quiet", "moderate", "loud"]
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        Form {
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
                    // Convert DatePicker times to the stored String format
                    viewModel.hoursOpen = timeFormatter.string(from: openTime)
                    viewModel.hoursClose = timeFormatter.string(from: closeTime)
                    viewModel.postedBy = UserDefaults.standard.string(forKey: "displayName") ?? ""
                    Task {
                        await viewModel.save()
                        dismiss()
                    }
                }
                .disabled(viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .onAppear {
            viewModel.autofillLocation(from: locationManager)
        }
    }
}
