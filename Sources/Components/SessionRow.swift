import SwiftUI

struct SessionRow: View {
    let session: GrappleSession

    private var outcomeColor: Color {
        switch session.outcome {
        case .strong: return Theme.Colors.success
        case .mixed: return Theme.Colors.warning
        case .weak: return Theme.Colors.danger
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.createdAt)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(session.topic)
                    .font(Theme.Typography.textMedium(Theme.Typography.bodyLarge))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(formattedDate)
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text("•")
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text(session.debateMode.rawValue)
                        .font(Theme.Typography.mono(Theme.Typography.caption))

                    Text("•")
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text("\(session.counterArguments.count) args")
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            Spacer()

            Text(session.outcome.rawValue)
                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                .foregroundColor(outcomeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(outcomeColor.opacity(0.15))
                .cornerRadius(4)

            Image(systemName: "chevron.right")
                .font(.system(size: Theme.Typography.caption2, weight: .semibold))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(sessionRowAccessibilityLabel(
            topic: session.topic,
            outcome: session.outcome.rawValue,
            argumentCount: session.counterArguments.count
        ))
    }
}
