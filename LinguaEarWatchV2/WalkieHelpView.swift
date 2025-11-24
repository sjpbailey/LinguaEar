import SwiftUI

struct WalkieHelpView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("LinguaEar Walkie V2")
                .font(.title2)
                .bold()

            Text("This is the V2 test screen running on the watch.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer().frame(height: 12)

            Button {
                // we'll hook this up later
                print("Walkie V2 mic tapped")
            } label: {
                Label("Hold to talk", systemImage: "mic.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    WalkieHelpView()
}
