import SwiftUI

struct RebuttalField: View {
    let argument: CounterArgument
    @Binding var rebuttal: Rebuttal
    let isJudging: Bool
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    private var judgmentColor: Color {
        guard !rebuttal.text.isEmpty else { return Color(hex: "2D3F54") }
        switch rebuttal.judgment {
        case .strong: return Color(hex: "52B788")
        case .partial: return Color(hex: "F4A261")
        case .weak: return Color(hex: "E63946")
        }
    }

    private var canSubmit: Bool {
        rebuttal.text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(argument.type.icon)
                    .font(.system(size: 12))

                Text("Your rebuttal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "8B9BB4"))

                Spacer()

                if isJudging {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(Color(hex: "4A90D9"))
                } else if !rebuttal.text.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(rebuttal.judgment.icon)
                            .font(.system(size: 14))
                        Text(rebuttal.confidenceLevel.rawValue)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color(hex: rebuttal.confidenceLevel.color))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "243044"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(judgmentColor, lineWidth: 1.5)
                    )

                TextEditor(text: $rebuttal.text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .focused($isFocused)

                if rebuttal.text.isEmpty {
                    Text("Type your rebuttal to this challenge...")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "8B9BB4"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: 100)

            // Manual submit button — no auto-judgment on keystroke
            HStack {
                Spacer()
                Button(action: {
                    if canSubmit {
                        onSubmit()
                    }
                }) {
                    Text(isJudging ? "Judging..." : (canSubmit ? "Submit Rebuttal" : "Enter at least 20 characters"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(canSubmit ? Color(hex: "4A90D9") : Color(hex: "8B9BB4"))
                }
                .disabled(!canSubmit || isJudging)
            }
        }
        .padding(16)
        .background(Color(hex: "1A2332"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "4A90D9"))
                .frame(width: 3),
            alignment: .leading
        )
        .cornerRadius(8)
    }
}
