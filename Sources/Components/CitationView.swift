import SwiftUI

struct CitationView: View {
    let citation: Citation
    @State private var showFullCitation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Compact citation chip
            Button(action: {
                Haptics.toggle()
                showFullCitation.toggle()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "link")
                        .font(.system(size: 10))

                    Text(citation.shortDomain)
                        .font(Theme.Typography.mono(Theme.Typography.caption))

                    Image(systemName: showFullCitation ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundColor(Theme.Colors.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Theme.Colors.primary.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Citation from \(citation.shortDomain)")
            .accessibilityHint(showFullCitation ? "Double-tap to collapse" : "Double-tap to expand")

            if showFullCitation {
                VStack(alignment: .leading, spacing: 6) {
                    // Source title
                    Text(citation.displayTitle)
                        .font(Theme.Typography.textSemibold(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(2)

                    // URL
                    Text(citation.sourceURL)
                        .font(Theme.Typography.mono(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.primary)
                        .lineLimit(1)

                    // Relevant quote
                    if let quote = citation.relevantQuote, !quote.isEmpty {
                        Text("\"\(quote)\"")
                            .font(Theme.Typography.mono(Theme.Typography.caption))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .italic()
                            .lineLimit(3)
                    }

                    // Page/section
                    if let section = citation.pageSection {
                        Text(section)
                            .font(Theme.Typography.text(10))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                }
                .padding(10)
                .background(Theme.Colors.surfaceElevated)
                .cornerRadius(Theme.CornerRadius.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showFullCitation)
    }
}

struct CitationsListView: View {
    let citations: [Citation]

    var body: some View {
        if !citations.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: Theme.Typography.caption))
                    Text("Sources (\(citations.count))")
                        .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.primary)
                }

                ForEach(citations) { citation in
                    CitationView(citation: citation)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                Rectangle()
                    .fill(Theme.Colors.primary)
                    .frame(width: 2),
                alignment: .leading
            )
        }
    }
}
