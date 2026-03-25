import SwiftUI

struct SessionRow: View {
    let session: GrappleSession

    private var outcomeColor: Color {
        switch session.outcome {
        case .strong: return Color(hex: "52B788")
        case .mixed: return Color(hex: "F4A261")
        case .weak: return Color(hex: "E63946")
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))

                    Text("•")
                        .foregroundColor(Color(hex: "8B9BB4"))

                    Text("\(session.counterArguments.count) challenges")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }
            }

            Spacer()

            Text(session.outcome.rawValue)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(outcomeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(outcomeColor.opacity(0.15))
                .cornerRadius(4)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "8B9BB4"))
        }
        .padding(16)
        .background(Color(hex: "1A2332"))
        .cornerRadius(8)
    }
}
