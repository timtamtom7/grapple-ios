import SwiftUI

struct ArgumentCard: View {
    let argument: CounterArgument
    let isExpanded: Bool
    let onToggle: () -> Void

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
            HStack(spacing: 8) {
                Text(argument.type.icon)
                    .font(.system(size: 14))

                Text(argument.type.rawValue)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(strengthColor)

                Spacer()

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
                    Text(argument.type.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))

                    HStack {
                        Text("Severity: \(argument.severity)/3")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        Spacer()

                        Text("Confidence: \(Int(argument.confidenceScore * 100))%")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(strengthColor)
                    }

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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
