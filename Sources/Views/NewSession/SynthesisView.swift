import SwiftUI

struct SynthesisView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @State private var showFactChecks = true
    @State private var appeared = false
    @State private var navigateToHistory = false
    @State private var showingShareSheet = false
    @State private var sharePDFURL: URL?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with dramatic reveal
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(hex: "52B788"))
                            Text("Synthesis Complete")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "52B788"))
                        }

                        Text("Here's how your thinking held up under pressure.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B9BB4"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)

                    if let synth = viewModel.synthesis {
                        // Overall confidence banner
                        HStack(spacing: 8) {
                            Image(systemName: synth.overallConfidence == .high ? "checkmark.circle.fill" : (synth.overallConfidence == .medium ? "exclamationmark.circle.fill" : "xmark.circle.fill"))
                                .font(.system(size: 16))
                            Text("Overall Confidence: \(synth.overallConfidence.rawValue)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(Color(hex: synth.overallConfidence.color))
                        .padding(.horizontal, 16)

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
                        .background(
                            Color(hex: "52B788").opacity(0.08)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "52B788").opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.95)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)

                        // Sections
                        SynthesisSection(
                            title: "What Survived",
                            icon: "✅",
                            content: synth.whatSurvived,
                            color: Color(hex: "52B788")
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3), value: appeared)

                        SynthesisSection(
                            title: "What Collapsed",
                            icon: "❌",
                            content: synth.whatCollapsed,
                            color: Color(hex: "E63946")
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.4), value: appeared)

                        SynthesisSection(
                            title: "Needs Evidence",
                            icon: "🔍",
                            content: synth.needsEvidence,
                            color: Color(hex: "F4A261")
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.5), value: appeared)

                        // Fact Check Section
                        if !synth.factChecks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "4A90D9"))
                                    Text("Real-Time Fact Check")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "4A90D9"))

                                    Spacer()

                                    Button(action: { showFactChecks.toggle() }) {
                                        Image(systemName: showFactChecks ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "8B9BB4"))
                                    }
                                }

                                if showFactChecks {
                                    ForEach(synth.factChecks) { item in
                                        FactCheckCard(item: item)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(hex: "1A2332"))
                            .cornerRadius(8)
                            .overlay(
                                Rectangle()
                                    .fill(Color(hex: "4A90D9"))
                                    .frame(width: 3),
                                alignment: .leading
                            )
                            .padding(.horizontal, 16)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 15)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.6), value: appeared)
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
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.7), value: appeared)

                        // R4: Export as PDF
                        Button(action: exportPDF) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 13))
                                Text("Export as PDF")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "4A90D9"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "1A2332"))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.8), value: appeared)
                    }

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

                    Button(action: {
                        viewModel.reset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .semibold))

                            Text("Change my Mind")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "4A90D9"))
                        )
                    }

                    NavigationLink(destination: HistoryView(viewModel: historyViewModel)) {
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
                                .fill(Color(hex: "243044"))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "0F1419"))
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = sharePDFURL {
                ShareSheet(activityItems: [url])
            }
        }
        .onAppear {
            appeared = true
        }
    }

    private func exportPDF() {
        let session = GrappleSession(
            topic: viewModel.topic,
            originalInput: viewModel.inputText,
            counterArguments: viewModel.counterArguments,
            rebuttals: viewModel.rebuttals,
            synthesis: viewModel.synthesis,
            outcome: .mixed,
            debateMode: viewModel.debateMode,
            sourceURLs: viewModel.sourceURLs,
            factChecks: viewModel.synthesis?.factChecks ?? []
        )
        sharePDFURL = PDFExportService.shared.saveSynthesisPDF(session: session)
        if sharePDFURL != nil {
            showingShareSheet = true
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

struct FactCheckCard: View {
    let item: FactCheckItem

    var confidenceColor: Color {
        Color(hex: item.confidence.color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(confidenceColor)
                    .frame(width: 6, height: 6)
                Text(item.confidence.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(confidenceColor)
            }

            Text("\"\(item.claim)\"")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color(hex: "E63946"))
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                Text(item.actualData)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8B9BB4"))
            }
        }
        .padding(12)
        .background(Color(hex: "243044"))
        .cornerRadius(6)
    }
}
