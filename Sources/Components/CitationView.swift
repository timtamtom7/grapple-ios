import SwiftUI

struct CitationView: View {
    let citation: Citation
    @State private var showFullCitation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Compact citation chip
            Button(action: { showFullCitation.toggle() }) {
                HStack(spacing: 5) {
                    Image(systemName: "link")
                        .font(.system(size: 10))

                    Text(citation.shortDomain)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))

                    Image(systemName: showFullCitation ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundColor(Color(hex: "4A90D9"))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color(hex: "4A90D9").opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "4A90D9").opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            if showFullCitation {
                VStack(alignment: .leading, spacing: 6) {
                    // Source title
                    Text(citation.displayTitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // URL
                    Text(citation.sourceURL)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(hex: "4A90D9"))
                        .lineLimit(1)

                    // Relevant quote
                    if let quote = citation.relevantQuote, !quote.isEmpty {
                        Text("\"\(quote)\"")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .italic()
                            .lineLimit(3)
                    }

                    // Page/section
                    if let section = citation.pageSection {
                        Text(section)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                }
                .padding(10)
                .background(Color(hex: "243044"))
                .cornerRadius(6)
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
                        .font(.system(size: 11))
                    Text("Sources (\(citations.count))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "4A90D9"))
                }

                ForEach(citations) { citation in
                    CitationView(citation: citation)
                }
            }
            .padding(12)
            .background(Color(hex: "1A2332"))
            .cornerRadius(8)
            .overlay(
                Rectangle()
                    .fill(Color(hex: "4A90D9"))
                    .frame(width: 2),
                alignment: .leading
            )
        }
    }
}
