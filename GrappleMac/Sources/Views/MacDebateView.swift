import SwiftUI
import Combine

struct MacDebateView: View {
    @StateObject private var viewModel = MacGrappleViewModel()
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("New Grapple")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(MacTheme.primaryText)
                    Text("Test your thinking with rigorous counter-arguments")
                        .font(.system(size: 13))
                        .foregroundColor(MacTheme.secondaryText)
                }
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            Divider()
                .background(MacTheme.divider)

            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.state == .idle {
                        inputSection
                    } else if viewModel.state == .grappling {
                        challengeSection
                    } else if viewModel.state == .rebutting {
                        rebuttalSection
                    } else if viewModel.state == .synthesizing {
                        synthesisSection
                    } else if viewModel.state == .done {
                        doneSection
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MacTheme.background)
        }
        .background(MacTheme.background)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Thought")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.secondaryText)

                TextEditor(text: $inputText)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundColor(MacTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .background(MacTheme.surface)
                    .frame(minHeight: 180)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: MacTheme.cornerRadius)
                            .stroke(MacTheme.divider, lineWidth: 1)
                    )
                    .focused($isInputFocused)
                    .overlay(alignment: .topLeading) {
                        if inputText.isEmpty {
                            Text("Paste a thought, belief, plan, or piece of writing you want to test...")
                                .font(.system(size: 15, design: .monospaced))
                                .foregroundColor(MacTheme.secondaryText.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
            }

            HStack {
                Spacer()
                Button {
                    let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.count >= 20 else { return }
                    viewModel.startGrapple(with: trimmed)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                        Text("Challenge Me")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20 ? MacTheme.challenge : MacTheme.elevated)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).count < 20)
                .accessibilityLabel("Challenge Me")
                .accessibilityHint("Submit your thought to be challenged")
            }
        }
    }

    // MARK: - Challenge Section

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Original input recap
            VStack(alignment: .leading, spacing: 6) {
                Text("YOUR CLAIM")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(MacTheme.secondaryText)
                Text(viewModel.originalInput)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(MacTheme.primaryText)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MacTheme.surface)
                    .cornerRadius(8)
            }

            Text("COUNTER-ARGUMENTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(MacTheme.secondaryText)

            ForEach(Array(viewModel.counterArguments.enumerated()), id: \.element.id) { index, argument in
                MacArgumentCard(argument: argument, index: index + 1)
            }

            HStack {
                Spacer()
                Button {
                    viewModel.proceedToRebuttals()
                } label: {
                    HStack(spacing: 8) {
                        Text("Respond to All")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(MacTheme.rebuttal)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Respond to All")
                .accessibilityHint("Write your rebuttals to all counter-arguments")
            }
        }
    }

    // MARK: - Rebuttal Section

    private var rebuttalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(viewModel.counterArguments.enumerated()), id: \.element.id) { index, argument in
                MacRebuttalCard(
                    argument: argument,
                    index: index + 1,
                    rebuttalText: Binding(
                        get: { viewModel.rebuttalTexts[argument.id] ?? "" },
                        set: { viewModel.rebuttalTexts[argument.id] = $0 }
                    ),
                    judgment: viewModel.rebuttalJudgments[argument.id]
                )
            }

            HStack {
                Spacer()
                Button {
                    viewModel.submitRebuttals()
                } label: {
                    HStack(spacing: 8) {
                        Text("Submit Rebuttals")
                        Image(systemName: "paperplane.fill")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(MacTheme.success)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Submit Rebuttals")
                .accessibilityHint("Submit your rebuttals to generate a synthesis")
            }
        }
    }

    // MARK: - Synthesis Section

    private var synthesisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(MacTheme.success)
                Text("Synthesis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.7)
            }

            if let synthesis = viewModel.synthesis {
                MacSynthesisCard(synthesis: synthesis)
            } else {
                HStack {
                    Spacer()
                    Text("Generating synthesis...")
                        .foregroundColor(MacTheme.secondaryText)
                    Spacer()
                }
                .padding(40)
            }
        }
    }

    // MARK: - Done Section

    private var doneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(MacTheme.success)
                Text("Session Complete")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                Spacer()
                OutcomeBadge(outcome: viewModel.session?.outcome ?? .mixed)
            }

            if let synthesis = viewModel.synthesis {
                MacSynthesisCard(synthesis: synthesis)
            }

            HStack {
                Spacer()
                Button {
                    viewModel.reset()
                    inputText = ""
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("New Grapple")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(MacTheme.elevated)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("New Grapple")
                .accessibilityHint("Start a new debate session from scratch")
            }
        }
    }
}

// MARK: - Supporting Views

struct MacArgumentCard: View {
    let argument: CounterArgument
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(index).")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.challenge)
                ArgumentTypeBadge(type: argument.type)
                Spacer()
                SeverityIndicator(severity: argument.severity)
            }
            Text(argument.text)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(MacTheme.primaryText)
                .lineSpacing(4)
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
        .overlay(
            HStack {
                Rectangle()
                    .fill(MacTheme.challenge)
                    .frame(width: 3)
                Spacer()
            }
        )
    }
}

struct ArgumentTypeBadge: View {
    let type: ArgumentType

    var body: some View {
        HStack(spacing: 4) {
            Text(type.icon)
            Text(type.rawValue)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(4)
    }

    private var badgeColor: Color {
        switch type {
        case .factual: return MacTheme.challenge
        case .logical: return MacTheme.rebuttal
        case .emotional: return Color.orange
        case .practical: return MacTheme.success
        }
    }
}

struct SeverityIndicator: View {
    let severity: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...3, id: \.self) { level in
                Circle()
                    .fill(level <= severity ? MacTheme.challenge : MacTheme.divider)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

struct MacRebuttalCard: View {
    let argument: CounterArgument
    let index: Int
    @Binding var rebuttalText: String
    let judgment: RebuttalJudgment?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Counter-argument
            HStack {
                Text("\(index). [Challenge]")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(MacTheme.challenge)
                ArgumentTypeBadge(type: argument.type)
                Spacer()
            }
            Text(argument.text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(MacTheme.secondaryText)
                .lineSpacing(3)

            // Rebuttal input
            TextEditor(text: $rebuttalText)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(MacTheme.primaryText)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .padding(10)
                .background(MacTheme.elevated)
                .cornerRadius(8)
                .overlay(alignment: .topLeading) {
                    if rebuttalText.isEmpty {
                        Text("Your rebuttal...")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(MacTheme.secondaryText.opacity(0.5))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }

            if let judgment = judgment {
                HStack {
                    Text(judgment.icon)
                    Text(judgment.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(judgmentColor(judgment))
            }
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }

    private func judgmentColor(_ j: RebuttalJudgment) -> Color {
        switch j {
        case .strong: return MacTheme.success
        case .partial: return Color.orange
        case .weak: return MacTheme.challenge
        }
    }
}

struct MacSynthesisCard: View {
    let synthesis: Synthesis

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SynthesisSection(title: "What Survived", icon: "checkmark.shield", color: MacTheme.success, content: synthesis.whatSurvived)
            SynthesisSection(title: "What Collapsed", icon: "xmark.shield", color: MacTheme.challenge, content: synthesis.whatCollapsed)
            SynthesisSection(title: "What Needs Evidence", icon: "questionmark.circle", color: Color.orange, content: synthesis.needsEvidence)
            SynthesisSection(title: "Final Verdict", icon: "gavel", color: MacTheme.rebuttal, content: synthesis.verdict, isVerdict: true)
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }
}

struct SynthesisSection: View {
    let title: String
    let icon: String
    let color: Color
    let content: String
    var isVerdict: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(color)

            Text(content)
                .font(.system(size: 14, design: isVerdict ? .monospaced : .default))
                .foregroundColor(isVerdict ? MacTheme.primaryText : MacTheme.secondaryText)
                .fontWeight(isVerdict ? .semibold : .regular)
        }
    }
}

struct OutcomeBadge: View {
    let outcome: SessionOutcome

    var body: some View {
        HStack(spacing: 4) {
            Text(outcome.rawValue)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(6)
    }

    private var badgeColor: Color {
        switch outcome {
        case .strong: return MacTheme.success
        case .mixed: return Color.orange
        case .weak: return MacTheme.challenge
        }
    }
}

#Preview {
    MacDebateView()
}
