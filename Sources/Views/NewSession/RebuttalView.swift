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
                            .font(Theme.Typography.displaySemibold(Theme.Typography.heading1))
                            .foregroundColor(Theme.Colors.textPrimary)

                        HStack {
                            Text("Judge each challenge:")
                                .font(Theme.Typography.text(Theme.Typography.body))
                                .foregroundColor(Theme.Colors.textSecondary)

                            Text("\(viewModel.rebuttalsEntered) of \(viewModel.counterArguments.count) entered")
                                .font(Theme.Typography.textMedium(Theme.Typography.body))
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.xxl)

                    // Rebuttal fields
                    VStack(spacing: Theme.Spacing.lg) {
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
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Legend
                    HStack(spacing: Theme.Spacing.lg) {
                        LegendItem(icon: "✅", label: "Strong")
                        LegendItem(icon: "⚠️", label: "Partial")
                        LegendItem(icon: "❌", label: "Weak")
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.divider)

                Button(action: {
                    Haptics.submit()
                    Task {
                        await viewModel.submitRebuttals()
                    }
                }) {
                    HStack {
                        Text("Submit Rebuttals")
                            .font(Theme.Typography.textSemibold(Theme.Typography.button))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                            .fill(allRebuttalsEntered ? Theme.Colors.primary : Theme.Colors.disabled)
                    )
                }
                .disabled(!allRebuttalsEntered)
                .accessibilityLabel(allRebuttalsEntered ? "Submit rebuttals" : "Submit rebuttals (all fields must be completed)")
                .accessibilityHint("Double-tap to submit your rebuttals and view synthesis")
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
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
                .font(.system(size: Theme.Typography.caption2))

            Text(label)
                .font(Theme.Typography.text(Theme.Typography.caption))
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}
