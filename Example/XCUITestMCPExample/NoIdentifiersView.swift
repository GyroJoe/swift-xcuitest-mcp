import SwiftUI

struct NoIdentifiersView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var agreedToTerms = false
    @State private var selectedColor = "Red"
    @State private var message = "Fill out the form"
    let colors = ["Red", "Green", "Blue", "Orange"]

    var body: some View {
        Form {
            Section("Personal Info") {
                TextField("Full Name", text: $name)
                TextField("Email Address", text: $email)
            }

            Section("Preferences") {
                Picker("Favorite Color", selection: $selectedColor) {
                    ForEach(colors, id: \.self) { Text($0) }
                }
                Toggle("I agree to the terms", isOn: $agreedToTerms)
            }

            Section {
                Button("Sign Up") {
                    message = "Welcome, \(name)!"
                }
                .disabled(name.isEmpty || !agreedToTerms)

                Button("Clear Form") {
                    name = ""
                    email = ""
                    agreedToTerms = false
                    selectedColor = "Red"
                    message = "Fill out the form"
                }
            }

            Text(message)
                .font(.headline)
        }
        .navigationTitle("Sign Up")
    }
}
