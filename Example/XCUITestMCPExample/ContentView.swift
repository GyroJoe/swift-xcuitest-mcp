import SafariServices
import SwiftUI

struct ContentView: View {
    @State private var textFieldValue = ""
    @State private var notesValue = ""
    @State private var toggleOn = false
    @State private var counter = 0
    @State private var statusText = "Ready"
    @State private var showingDetail = false
    @State private var showingModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status display
                    Text(statusText)
                        .font(.headline)
                        .accessibilityIdentifier("statusLabel")

                    // Text input
                    TextField("Enter text here", text: $textFieldValue)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("mainTextField")

                    TextField("Notes", text: $notesValue)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("notesTextField")

                    // Counter section
                    HStack(spacing: 16) {
                        Button("Decrement") {
                            counter -= 1
                            statusText = "Counter: \(counter)"
                        }
                        .accessibilityIdentifier("decrementButton")

                        Text("\(counter)")
                            .font(.title2)
                            .frame(minWidth: 40)
                            .accessibilityIdentifier("counterLabel")

                        Button("Increment") {
                            counter += 1
                            statusText = "Counter: \(counter)"
                        }
                        .accessibilityIdentifier("incrementButton")
                    }

                    // Action buttons
                    Button("Submit") {
                        statusText = "Submitted: \(textFieldValue)"
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("submitButton")

                    Button("Reset") {
                        textFieldValue = ""
                        counter = 0
                        toggleOn = false
                        statusText = "Ready"
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("resetButton")

                    // Toggle
                    Toggle("Enable Feature", isOn: $toggleOn)
                        .accessibilityIdentifier("featureToggle")
                        .onChange(of: toggleOn) {
                            statusText = toggleOn ? "Feature ON" : "Feature OFF"
                        }

                    // Swipe area
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.15))
                        .frame(height: 80)
                        .overlay(Text("Swipe here"))
                        .accessibilityIdentifier("swipeArea")
                        .gesture(
                            DragGesture(minimumDistance: 50)
                                .onEnded { value in
                                    let h = value.translation.width
                                    let v = value.translation.height
                                    if abs(h) > abs(v) {
                                        statusText = h > 0 ? "Swiped right" : "Swiped left"
                                    } else {
                                        statusText = v > 0 ? "Swiped down" : "Swiped up"
                                    }
                                }
                        )

                    // Navigation
                    NavigationLink("Go to Detail") {
                        DetailView()
                    }
                    .accessibilityIdentifier("detailLink")

                    NavigationLink("No Identifiers Screen") {
                        NoIdentifiersView()
                    }

                    NavigationLink("Web View") {
                        WebViewScreen()
                    }
                    .accessibilityIdentifier("webViewLink")

                    Button("Show Modal") {
                        showingModal = true
                    }
                    .accessibilityIdentifier("showModalButton")

                    Button("Safari View") {
                        let safari = SFSafariViewController(url: URL(string: "https://www.microsoft.com")!)
                        UIApplication.shared.connectedScenes
                            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
                            .first?.present(safari, animated: true)
                    }
                    .accessibilityIdentifier("safariViewButton")

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("MCP Test App")
            .sheet(isPresented: $showingModal) {
                ModalView()
            }
        }
    }
}
