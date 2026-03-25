import SwiftUI

struct SynthesisView: View {
    @ObservedObject var viewModel: GrappleViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synthesis")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Here's how your thinking held up under pressure.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B9BB4"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    if let synth = viewModel.synthesis {
                        // Verdict banner
                        VStack(spacing: 12) {
                            Text("Final Verdict")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "52B788"))

                            Text(synth.verdict)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "52B788").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "52B788").opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                        // Sections
                        SynthesisSection(
                            title: "What Survived",
                            icon: "✅",
                            content: synth.whatSurvived,
                            color: Color(hex: "52B788")
                        )

                        SynthesisSection(
                            title: "What Collapsed",
                            icon: "❌",
                            content: synth.whatCollapsed,
                            color: Color(hex: "E63946")
                        )

                        SynthesisSection(
                            title: "Needs Evidence",
                            icon: "🔍",
                            content: synth.needsEvidence,
                            color: Color(hex: "F4A261")
                        )
                    }

                    // Stats summary
                    HStack(spacing: 12) {
                        StatBadge(
                            label: "Strong",
                            count: viewModel.rebuttals.filter { $0.judgment == .strong }.count,
                            color: Color(hex: "52B788")
                        )
                        StatBadge(
                            label: "Partial",
                            count: viewModel.rebuttals.filter { $0.judgment == .partial }.count,
                            color: Color(hex: "F4A261")
                        )
                        StatBadge(
                            label: "Weak",
                            count: viewModel.rebuttals.filter { $0.judgment == .weak }.count,
                            color: Color(hex: "E63946")
                        )
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Color(hex: "2D3F54"))

                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.reset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15, weight: .semibold))

                            Text("New Grapple")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "243044"))
                        )
                    }

                    NavigationLink(destination: HistoryView(viewModel: HistoryViewModel())) {
                        HStack {
                            Text("History")
                                .font(.system(size: 17, weight: .semibold))

                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "4A90D9"))
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "0F1419"))
        }
    }
}

struct SynthesisSection: View {
    let title: String
    let icon: String
    let content: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 14))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(content)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineSpacing(4)
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
        .padding(.horizontal, 16)
    }
}

struct StatBadge: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "8B9BB4"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(hex: "1A2332"))
        .cornerRadius(8)
    }
}
