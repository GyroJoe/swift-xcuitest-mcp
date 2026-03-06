import SwiftUI

struct ModalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Modal Content")
                    .font(.title)
                    .accessibilityIdentifier("modalTitle")

                Button("Modal Action") { }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("modalActionButton")

                Button("Close Modal") {
                    dismiss()
                }
                .accessibilityIdentifier("closeModalButton")
            }
            .padding()
            .navigationTitle("Modal Screen")
        }
    }
}
