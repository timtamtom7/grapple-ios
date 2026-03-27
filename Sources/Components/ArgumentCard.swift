import SwiftUI

// Color(hex:) is defined in Sources/Extensions/Color+Hex.swift

struct ArgumentCard: View {
    let argument: CounterArgument
    let isExpanded: Bool
    let onToggle: () -> Void
    var onFactCheck: ((String) async -> FactCheckItem?)?

    private var strengthColor: Color {
        switch argument.confidenceLevel {
        case .high: return Theme.Colors.danger
        case .medium: return Theme.Colors.warning
        case .low: return Color(hex: "6B3A3A")
        }
    }

    private var severityColor: Color {
        switch argument.severity {
        case 3: return Theme.Colors.danger
        case 2: return Theme.Colors.warning
        default: return Theme.Colors.primary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Top row: type badge + controls
            HStack(spacing: Theme.Spacing.sm) {
                Text(argument.type.icon)
                    .font(.system(size: 14))

                Text(argument.type.rawValue)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(strengthColor)

                Spacer()

                // Citation indicator
                if !argument.citations.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10))
                        Text("\(argument.citations.count)")
                            .font(Theme.Typography.mono(Theme.Typography.caption))
                    }
                    .foregroundColor(Theme.Colors.primary)
                }

                // Confidence indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(strengthColor)
                        .frame(width: 6, height: 6)
                    Text(argument.confidenceLevel.rawValue)
                        .font(Theme.Typography.mono(Theme.Typography.caption))
                        .foregroundColor(strengthColor)
                }

                // Severity dots
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { level in
                        Circle()
                            .fill(level <= argument.severity ? severityColor : Theme.Colors.divider)
                            .frame(width: 6, height: 6)
                    }
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: Theme.Typography.caption2, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Text(argument.text)
                .font(Theme.Typography.mono(Theme.Typography.bodyMono))
                .foregroundColor(Theme.Colors.textPrimary)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)

            if isExpanded {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    // Type description
                    Text(argument.type.description)
                        .font(Theme.Typography.text(Theme.Typography.caption2))

                    // Stats row
                    HStack {
                        Text("Severity: \(argument.severity)/3")
                            .font(Theme.Typography.mono(Theme.Typography.caption))
                            .foregroundColor(Theme.Colors.textSecondary)

                        Spacer()

                        Text("Confidence: \(Int(argument.confidenceScore * 100))%")
                            .font(Theme.Typography.mono(Theme.Typography.caption))
                            .foregroundColor(strengthColor)
                    }

                    // Source attribution
                    if let source = argument.sourceAttribution {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 10))
                            Text(source)
                                .font(Theme.Typography.mono(Theme.Typography.caption))
                                .lineLimit(1)
                        }
                        .foregroundColor(Theme.Colors.primary)
                    }

                    // Citations
                    if !argument.citations.isEmpty {
                        CitationsListView(citations: argument.citations)
                    }

                    // Fact check button
                    if let onFactCheck = onFactCheck {
                        FactCheckButton(claim: argument.text, onCheck: onFactCheck)
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.surface)
        .overlay(
            Rectangle()
                .fill(strengthColor)
                .frame(width: 3),
            alignment: .leading
        )
        .cornerRadius(Theme.CornerRadius.md)
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.expand()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                onToggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(argumentAccessibilityLabel(
            type: argument.type.rawValue,
            severity: argument.severity,
            confidence: argument.confidenceLevel.rawValue
        ))
        .accessibilityHint(isExpanded ? "Double-tap to collapse" : "Double-tap to expand details")
    }
}
