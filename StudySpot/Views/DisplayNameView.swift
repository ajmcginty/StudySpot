import SwiftUI

struct DisplayNameView: View {
    @Binding var displayName: String
    @State private var nameInput: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "books.vertical.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)

            Text("StudySpot")
                .font(.title)

            Text("What should we call you?")
                .foregroundStyle(.secondary)

            TextField("Your name", text: $nameInput)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Get Started") {
                let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                UserDefaults.standard.set(trimmed, forKey: "displayName")
                displayName = trimmed
            }
            .buttonStyle(.borderedProminent)
            .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)

            Spacer()
        }
    }
}
