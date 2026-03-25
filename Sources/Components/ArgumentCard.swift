import SwiftUI

// Color(hex:) is defined in Sources/Extensions/Color+Hex.swift

struct ArgumentCard: View {
    let argument: CounterArgument
    let isExpanded: Bool
    let onToggle: () -> Void
    var onFactCheck: ((String) async -> FactCheckItem?)?

    private var strengthColor: Color {
        switch argument.confidenceLevel {
        case .high: return Color(hex: "E63946")  // bright red - strong claim
        case .medium: return Color(hex: "F4A261") // amber - moderate
        case .low: return Color(hex: "6B3A3A")   // dim red - weak claim
        }
    }

    private var severityColor: Color {
        switch argument.severity {
        case 3: return Color(hex: "E63946")
        case 2: return Color(hex: "F4A261")
        default: return Color(hex: "4A90D9")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: type badge + controls
            HStack(spacing: 8) {
                Text(argument.type.icon)
                    .font(.system(size: 14))

                Text(argument.type.rawValue)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(strengthColor)

                Spacer()

                // Citation indicator
                if !argument.citations.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10))
                        Text("\(argument.citations.count)")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(Color(hex: "4A90D9"))
                }

                // Confidence indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(strengthColor)
                        .frame(width: 6, height: 6)
                    Text(argument.confidenceLevel.rawValue)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(strengthColor)
                }

                // Severity dots
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { level in
                        Circle()
                            .fill(level <= argument.severity ? severityColor : Color(hex: "2D3F54"))
                            .frame(width: 6, height: 6)
                    }
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "8B9BB4"))
            }

            Text(argument.text)
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.white)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // Type description
                    Text(argument.type.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))

                    // Stats row
                    HStack {
                        Text("Severity: \(argument.severity)/3")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        Spacer()

                        Text("Confidence: \(Int(argument.confidenceScore * 100))%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(strengthColor)
                    }

                    // Source attribution
                    if let source = argument.sourceAttribution {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 10))
                            Text(source)
                                .font(.system(size: 10, design: .monospaced))
                                .lineLimit(1)
                        }
                        .foregroundColor(Color(hex: "4A90D9"))
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
        .padding(16)
        .background(Color(hex: "1A2332"))
        .overlay(
            Rectangle()
                .fill(strengthColor)
                .frame(width: 3),
            alignment: .leading
        )
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                onToggle()
            }
        }
    }
}
