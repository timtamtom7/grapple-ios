import SwiftUI

#if canImport(UIKit)
struct SessionDetailView: View {
    let session: GrappleSession

    private var outcomeColor: Color {
        switch session.outcome {
        case .strong: return Theme.Colors.success
        case .mixed: return Theme.Colors.warning
        case .weak: return Theme.Colors.danger
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(session.topic)
                            .font(Theme.Typography.displayBold(Theme.Typography.heading2))
                            .foregroundColor(Theme.Colors.textPrimary)

                        Spacer()

                        Text(session.outcome.rawValue)
                            .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                            .foregroundColor(outcomeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(outcomeColor.opacity(0.15))
                            .cornerRadius(4)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: session.debateMode.icon)
                            .font(.system(size: Theme.Typography.caption))
                        Text(session.debateMode.rawValue)
                            .font(Theme.Typography.mono(Theme.Typography.caption))
                        Text("•")
                        Text(formattedDate)
                            .font(Theme.Typography.text(Theme.Typography.caption2))
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, 8)

                // Original input
                VStack(alignment: .leading, spacing: 8) {
                    Text("ORIGINAL THOUGHT")
                        .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text(session.originalInput)
                        .font(Theme.Typography.text(Theme.Typography.body))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineSpacing(4)
                        .padding(Theme.Spacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)

                // Counter arguments
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("CHALLENGES")
                        .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.textSecondary)

                    ForEach(session.counterArguments) { argument in
                        DetailArgumentRow(
                            argument: argument,
                            rebuttal: session.rebuttals.first { $0.argumentId == argument.id }
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)

                // Synthesis
                if let synth = session.synthesis {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("SYNTHESIS")
                            .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                            .foregroundColor(Theme.Colors.textSecondary)

                        VStack(spacing: Theme.Spacing.md) {
                            SynthRow(label: "Verdict", icon: "🎯", content: synth.verdict, color: Theme.Colors.success)
                            SynthRow(label: "Survived", icon: "✅", content: synth.whatSurvived, color: Theme.Colors.success)
                            SynthRow(label: "Collapsed", icon: "❌", content: synth.whatCollapsed, color: Theme.Colors.danger)
                            SynthRow(label: "Needs Evidence", icon: "🔍", content: synth.needsEvidence, color: Theme.Colors.warning)
                        }

                        // Fact checks
                        if !synth.factChecks.isEmpty {
                            Text("FACT CHECKS")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.primary)
                                .padding(.top, 4)

                            ForEach(synth.factChecks) { item in
                                FactCheckCard(item: item)
                            }
                        }

                        // Confidence
                        HStack {
                            Text("Overall Confidence:")
                                .font(Theme.Typography.text(Theme.Typography.caption2))
                                .foregroundColor(Theme.Colors.textSecondary)
                            Text(synth.overallConfidence.rawValue)
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption2))
                                .foregroundColor(Color(hex: synth.overallConfidence.color))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }

                Spacer(minLength: 32)
            }
        }
        .background(Theme.Colors.background)
        #if canImport(UIKit)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: session.createdAt)
    }
}

struct DetailArgumentRow: View {
    let argument: CounterArgument
    let rebuttal: Rebuttal?

    @State private var isExpanded = false

    private var strengthColor: Color {
        switch argument.confidenceLevel {
        case .high: return Theme.Colors.danger
        case .medium: return Theme.Colors.warning
        case .low: return Color(hex: "6B3A3A")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Argument header
            HStack(spacing: 8) {
                Text(argument.type.icon)
                    .font(.system(size: Theme.Typography.bodySmall))

                Text(argument.type.rawValue)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(strengthColor)

                Spacer()

                if let rebuttal = rebuttal {
                    Text(rebuttal.judgment.icon)
                        .font(.system(size: Theme.Typography.body))
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: Theme.Typography.caption, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            Text(argument.text)
                .font(Theme.Typography.mono(Theme.Typography.body))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)

            if isExpanded, let rebuttal = rebuttal {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Theme.Colors.divider)

                    Text("YOUR REBUTTAL")
                        .font(Theme.Typography.monoSemibold(10))
                        .foregroundColor(Theme.Colors.primary)

                    Text(rebuttal.text)
                        .font(Theme.Typography.text(Theme.Typography.body))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineSpacing(3)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            Rectangle()
                .fill(strengthColor)
                .frame(width: 3),
            alignment: .leading
        )
        .onTapGesture {
            Haptics.expand()
            withAnimation(.easeOut(duration: Theme.Animation.snappy)) {
                isExpanded.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(argument.type.rawValue) argument. \(argument.text). \(isExpanded ? "Expanded" : "Collapsed")")
    }
}

struct SynthRow: View {
    let label: String
    let icon: String
    let content: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: Theme.Typography.bodySmall))

                Text(label)
                    .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                    .foregroundColor(color)
            }

            Text(content)
                .font(Theme.Typography.text(Theme.Typography.body))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 3),
            alignment: .leading
        )
    }
}
#endif
