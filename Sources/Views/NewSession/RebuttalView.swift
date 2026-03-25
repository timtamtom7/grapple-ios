import SwiftUI

struct RebuttalView: View {
    @ObservedObject var viewModel: GrappleViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Response")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        HStack {
                            Text("Judge each challenge:")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B9BB4"))

                            Text("\(viewModel.rebuttalsEntered) of \(viewModel.counterArguments.count) entered")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "4A90D9"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Rebuttal fields
                    VStack(spacing: 16) {
                        ForEach(viewModel.counterArguments.indices, id: \.self) { index in
                            let argument = viewModel.counterArguments[index]
                            RebuttalField(
                                argument: argument,
                                rebuttal: $viewModel.rebuttals[index],
                                isJudging: viewModel.currentJudgmentIndex == index,
                                onSubmit: {
                                    Task {
                                        await viewModel.judgeRebuttal(at: index)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)

                    // Legend
                    HStack(spacing: 16) {
                        LegendItem(icon: "✅", label: "Strong")
                        LegendItem(icon: "⚠️", label: "Partial")
                        LegendItem(icon: "❌", label: "Weak")
                    }
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
                        await viewModel.submitRebuttals()
                    }
                }) {
                    HStack {
                        Text("Submit Rebuttals")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(allRebuttalsEntered ? Color(hex: "4A90D9") : Color(hex: "243044"))
                    )
                }
                .disabled(!allRebuttalsEntered)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "0F1419"))
        }
    }

    private var allRebuttalsEntered: Bool {
        viewModel.rebuttals.allSatisfy { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20 }
    }
}

struct LegendItem: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 12))

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "8B9BB4"))
        }
    }
}
