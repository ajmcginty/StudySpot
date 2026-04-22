import SwiftUI

struct AddSpotView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddSpotViewModel()

    var body: some View {
        Form {
            // TODO: name, description, hours pickers, weekend toggle,
            //       noise picker, outlets/wifi/groups toggles, photo picker
            Section("Spot Info") {
                TextField("Name", text: $viewModel.name)
                TextField("Description", text: $viewModel.description)
            }
        }
        .navigationTitle("Add Spot")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await viewModel.save()
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
