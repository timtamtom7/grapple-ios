import SwiftUI

struct RebuttalField: View {
    let argument: CounterArgument
    @Binding var rebuttal: Rebuttal
    let isJudging: Bool
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    private var judgmentColor: Color {
        guard !rebuttal.text.isEmpty else { return Theme.Colors.divider }
        switch rebuttal.judgment {
        case .strong: return Theme.Colors.success
        case .partial: return Theme.Colors.warning
        case .weak: return Theme.Colors.danger
        }
    }

    private var canSubmit: Bool {
        rebuttal.text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Text(argument.type.icon)
                    .font(.system(size: Theme.Typography.caption2))

                Text("Your rebuttal")
                    .font(Theme.Typography.textMedium(Theme.Typography.caption2))
                    .foregroundColor(Theme.Colors.textSecondary)

                Spacer()

                if isJudging {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(Theme.Colors.primary)
                } else if !rebuttal.text.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(rebuttal.judgment.icon)
                            .font(.system(size: Theme.Typography.caption2))
                        Text(rebuttal.confidenceLevel.rawValue)
                            .font(Theme.Typography.mono(Theme.Typography.caption))
                            .foregroundColor(Color(hex: rebuttal.confidenceLevel.color))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(Theme.Colors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .stroke(judgmentColor, lineWidth: 1.5)
                    )

                TextEditor(text: $rebuttal.text)
                    .font(Theme.Typography.text(Theme.Typography.body))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(Theme.Spacing.md)
                    .focused($isFocused)

                if rebuttal.text.isEmpty {
                    Text("Type your rebuttal to this challenge...")
                        .font(Theme.Typography.text(Theme.Typography.body))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: 100)

            // Manual submit button
            HStack {
                Spacer()
                Button(action: {
                    if canSubmit {
                        Haptics.judgmentReceived()
                        onSubmit()
                    }
                }) {
                    Text(isJudging ? "Judging..." : (canSubmit ? "Submit Rebuttal" : "Enter at least 20 characters"))
                        .font(Theme.Typography.textMedium(Theme.Typography.caption2))
                        .foregroundColor(canSubmit ? Theme.Colors.primary : Theme.Colors.textSecondary)
                }
                .disabled(!canSubmit || isJudging)
                .accessibilityLabel(isJudging ? "Judging rebuttal" : (canSubmit ? "Submit rebuttal" : "Minimum 20 characters required"))
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.surface)
        .overlay(
            Rectangle()
                .fill(Theme.Colors.primary)
                .frame(width: 3),
            alignment: .leading
        )
        .cornerRadius(Theme.CornerRadius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rebuttalAccessibilityLabel(
            type: argument.type.rawValue,
            judgment: rebuttal.judgment.rawValue,
            isEmpty: rebuttal.text.isEmpty
        ))
    }
}
