import SwiftUI

struct DetailView: View {
    @State private var sliderValue: Double = 50

    var body: some View {
        VStack(spacing: 20) {
            Text("Detail Screen")
                .font(.title)
                .accessibilityIdentifier("detailTitle")

            Slider(value: $sliderValue, in: 0...100)
                .accessibilityIdentifier("detailSlider")

            Text("Value: \(Int(sliderValue))")
                .accessibilityIdentifier("sliderValueLabel")

            Button("Action") {
                // placeholder action
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("detailActionButton")
        }
        .padding()
        .navigationTitle("Detail")
    }
}
