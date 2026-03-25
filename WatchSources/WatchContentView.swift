import SwiftUI
import WatchKit

struct WatchContentView: View {
    @State private var inputText: String = ""
    @State private var isGrappling: Bool = false
    @State private var grappleComplete: Bool = false
    @State private var resultMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if grappleComplete {
                    completionView
                } else if isGrappling {
                    grapplingView
                } else {
                    inputView
                }
            }
            .navigationTitle("Grapple")
        }
    }

    @ViewBuilder
    private var inputView: some View {
        VStack(spacing: 8) {
            Text("What's on your mind?")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.gray)

            TextField("Your thought...", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 12))
                .lineLimit(3...6)
                .frame(minHeight: 60)

            if inputText.count >= 15 {
                Button(action: startQuickGrapple) {
                    Label("Grapple", systemImage: "bolt.fill")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "4A90D9"))
            } else {
                Text("\(inputText.count)/15 min")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
    }

    @ViewBuilder
    private var grapplingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)

            Text("Grappling...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var completionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "52B788"))

            Text(resultMessage)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(4)

            Button("New Grapple") {
                reset()
            }
            .buttonStyle(.bordered)
            .font(.system(size: 11))
        }
        .padding(8)
    }

    private func startQuickGrapple() {
        isGrappling = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isGrappling = false
            grappleComplete = true
            // Quick mode: 3 challenges, go straight to synthesis
            let challenges = ["This claim lacks evidence.", "Hidden assumption detected.", "Implementation barriers exist."]
            resultMessage = challenges.randomElement() ?? "Consider this: your argument has merit but needs more evidence."
        }
    }

    private func reset() {
        inputText = ""
        grappleComplete = false
        isGrappling = false
        resultMessage = ""
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = (int >> 16) & 0xFF
        let g = (int >> 8) & 0xFF
        let b = int & 0xFF
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
