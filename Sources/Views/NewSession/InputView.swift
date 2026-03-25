import SwiftUI
import Speech

struct InputView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @State private var isRecording = false
    @FocusState private var isFocused: Bool

    private let speechRecognizer = SFSpeechRecognizer()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What do you want to test?")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Paste a thought, belief, plan, or writing — Grapple will find the strongest challenges.")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Input area
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "1A2332"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isFocused ? Color(hex: "4A90D9") : Color(hex: "2D3F54"), lineWidth: 1)
                            )

                        TextEditor(text: $viewModel.inputText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .padding(16)
                            .focused($isFocused)

                        if viewModel.inputText.isEmpty {
                            Text("What's on your mind? Paste a thought, belief, plan, or piece of writing you want to test...")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "8B9BB4"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(minHeight: 200)
                    .padding(.horizontal, 16)

                    // Character count & voice button row
                    HStack {
                        Text("\(viewModel.inputText.count) characters")
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.inputText.count >= 20 ? Color(hex: "52B788") : Color(hex: "8B9BB4"))

                        Spacer()

                        Button(action: toggleRecording) {
                            HStack(spacing: 6) {
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                Text(isRecording ? "Recording..." : "Voice")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isRecording ? Color(hex: "E63946") : Color(hex: "8B9BB4"))
                        }
                        .disabled(true) // Voice disabled in Round 1 (Speech framework setup required)
                    }
                    .padding(.horizontal, 16)

                    // Tip
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tip")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        Text("The more specific your thought, the sharper Grapple's challenges will be.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Color(hex: "2D3F54"))

                Button(action: {
                    Task {
                        await viewModel.startGrapple()
                    }
                }) {
                    HStack {
                        Text("Start Grapple")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.canStartGrapple ? Color(hex: "4A90D9") : Color(hex: "243044"))
                    )
                }
                .disabled(!viewModel.canStartGrapple)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "0F1419"))
        }
    }

    private func toggleRecording() {
        isRecording.toggle()
        // Voice recording implementation placeholder
    }
}
