import SwiftUI

struct SessionDetailView: View {
    let session: GrappleSession

    private var outcomeColor: Color {
        switch session.outcome {
        case .strong: return Color(hex: "52B788")
        case .mixed: return Color(hex: "F4A261")
        case .weak: return Color(hex: "E63946")
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(session.topic)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        Text(session.outcome.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(outcomeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(outcomeColor.opacity(0.15))
                            .cornerRadius(4)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: session.debateMode.icon)
                            .font(.system(size: 11))
                        Text(session.debateMode.rawValue)
                            .font(.system(size: 11, design: .monospaced))
                        Text("•")
                        Text(formattedDate)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: "8B9BB4"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Original input
                VStack(alignment: .leading, spacing: 8) {
                    Text("ORIGINAL THOUGHT")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "8B9BB4"))

                    Text(session.originalInput)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "1A2332"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)

                // Counter arguments
                VStack(alignment: .leading, spacing: 12) {
                    Text("CHALLENGES")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "8B9BB4"))

                    ForEach(session.counterArguments) { argument in
                        DetailArgumentRow(
                            argument: argument,
                            rebuttal: session.rebuttals.first { $0.argumentId == argument.id }
                        )
                    }
                }
                .padding(.horizontal, 16)

                // Synthesis
                if let synth = session.synthesis {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SYNTHESIS")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        VStack(spacing: 12) {
                            SynthRow(label: "Verdict", icon: "🎯", content: synth.verdict, color: Color(hex: "52B788"))
                            SynthRow(label: "Survived", icon: "✅", content: synth.whatSurvived, color: Color(hex: "52B788"))
                            SynthRow(label: "Collapsed", icon: "❌", content: synth.whatCollapsed, color: Color(hex: "E63946"))
                            SynthRow(label: "Needs Evidence", icon: "🔍", content: synth.needsEvidence, color: Color(hex: "F4A261"))
                        }

                        // Fact checks
                        if !synth.factChecks.isEmpty {
                            Text("FACT CHECKS")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "4A90D9"))
                                .padding(.top, 4)

                            ForEach(synth.factChecks) { item in
                                FactCheckCard(item: item)
                            }
                        }

                        // Confidence
                        HStack {
                            Text("Overall Confidence:")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "8B9BB4"))
                            Text(synth.overallConfidence.rawValue)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: synth.overallConfidence.color))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                }

                Spacer(minLength: 32)
            }
        }
        .background(Color(hex: "0F1419"))
        .navigationBarTitleDisplayMode(.inline)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Argument header
            HStack(spacing: 8) {
                Text(argument.type.icon)
                    .font(.system(size: 12))

                Text(argument.type.rawValue)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "E63946"))

                Spacer()

                if let rebuttal = rebuttal {
                    Text(rebuttal.judgment.icon)
                        .font(.system(size: 14))
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "8B9BB4"))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            Text(argument.text)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineSpacing(3)

            if isExpanded, let rebuttal = rebuttal {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Color(hex: "2D3F54"))

                    Text("YOUR REBUTTAL")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "4A90D9"))

                    Text(rebuttal.text)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .lineSpacing(3)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color(hex: "1A2332"))
        .cornerRadius(8)
        .overlay(
            Rectangle()
                .fill(Color(hex: "E63946"))
                .frame(width: 3),
            alignment: .leading
        )
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
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
                    .font(.system(size: 12))

                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(content)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A2332"))
        .cornerRadius(8)
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 3),
            alignment: .leading
        )
    }
}
