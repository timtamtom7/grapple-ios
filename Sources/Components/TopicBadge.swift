import SwiftUI

struct TopicBadge: View {
    let topic: String
    var isEditable: Bool = false
    var onEdit: (() -> Void)?

    var body: some View {
        HStack(spacing: 6) {
            Text(topic)
                .font(Theme.Typography.textMedium(Theme.Typography.bodySmall))
                .foregroundColor(.white)

            if isEditable {
                Image(systemName: "pencil")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.Colors.surfaceElevated)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.divider, lineWidth: 1)
        )
        .onTapGesture {
            Haptics.lightImpact()
            onEdit?()
        }
        .accessibilityLabel("Topic: \(topic)")
    }
}
