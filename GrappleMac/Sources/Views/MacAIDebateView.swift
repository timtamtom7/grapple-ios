import SwiftUI
import Combine

// MARK: - View Model

@MainActor
class MacAIDebateViewModel: ObservableObject {
    @Published var state: AIDebateState = .idle
    @Published var claimText: String = ""
    @Published var debate: AIDebate?
    @Published var currentRound: DebateRound = .opening
    @Published var isLoading: Bool = false
    @Published var evaluation: DebateEvaluation?
    @Published var detectedFallacies: [DetectedFallacy] = []
    @Published var fallacyReport: FallacyReport?
    @Published var userTurnContent: String = ""
    @Published var aiTurnContent: String = ""
    @Published var errorMessage: String?

    private let debateService = AIDebateService.shared
    private let fallacyService = FallacyDetectionService.shared

    var turnsForCurrentRound: [DebateTurn] {
        debate?.turns.filter { $0.round == currentRound } ?? []
    }

    var canAdvanceRound: Bool {
        guard let debate = debate else { return false }
        let roundTurns = debate.turns.filter { $0.round == currentRound }
        // Need at least one AI turn before advancing
        return !roundTurns.filter { $0.speaker == .ai }.isEmpty
    }

    var roundProgress: Double {
        guard let debate = debate else { return 0 }
        let totalRounds = DebateRound.allCases.count
        let completedRounds = DebateRound.allCases.firstIndex(of: debate.currentRound).map { $0 + 1 } ?? 0
        return Double(completedRounds) / Double(totalRounds)
    }

    // MARK: - Actions

    func startDebate() {
        guard !claimText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        state = .starting
        isLoading = true

        Task {
            do {
                // Create the debate
                let topic = detectTopic(from: claimText)
                let fallacyReport = try await fallacyService.generateFallacyReport(for: claimText)
                self.fallacyReport = fallacyReport
                self.detectedFallacies = fallacyReport.detectedFallacies

                var initialTurns: [DebateTurn] = []

                // Round 1: Opening — AI presents the challenge
                let aiOpening = try await debateService.generateOpening(for: claimText, speaker: .ai)
                initialTurns.append(aiOpening)

                let newDebate = AIDebate(
                    topic: topic,
                    originalClaim: claimText,
                    currentRound: .opening,
                    turns: initialTurns,
                    detectedFallacies: fallacyReport.detectedFallacies
                )

                self.debate = newDebate
                self.currentRound = .opening
                self.state = .debating
                self.isLoading = false

            } catch {
                self.errorMessage = "Failed to start debate: \(error.localizedDescription)"
                self.state = .idle
                self.isLoading = false
            }
        }
    }

    func submitUserResponse() {
        guard !userTurnContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              var debate = debate else { return }

        state = .submitting
        isLoading = true

        Task {
            do {
                let userTurn = DebateTurn(
                    round: currentRound,
                    speaker: .user,
                    content: userTurnContent
                )

                // Evaluate the user's turn
                let evaluation = try await debateService.evaluateTurn(userTurn, against: debate.originalClaim)
                self.evaluation = evaluation

                // Generate AI response for this round
                var aiTurn: DebateTurn

                switch currentRound {
                case .opening:
                    aiTurn = try await debateService.generateRebuttal(
                        for: debate.originalClaim,
                        opposingArgument: userTurnContent
                    )
                case .rebuttal:
                    aiTurn = try await debateService.generateCrossExamination(
                        for: debate.originalClaim,
                        previousTurn: userTurn
                    )
                case .crossExamination:
                    aiTurn = try await debateService.generateClosing(for: debate)
                case .closing:
                    aiTurn = DebateTurn(
                        round: .closing,
                        speaker: .ai,
                        content: "The debate has concluded. Review the summary above.",
                        isAIGenerated: true
                    )
                }

                debate.turns.append(userTurn)
                debate.turns.append(aiTurn)

                self.debate = debate
                self.userTurnContent = ""
                self.state = .debating
                self.isLoading = false

            } catch {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.state = .debating
                self.isLoading = false
            }
        }
    }

    func advanceToNextRound() {
        guard let debate = debate else { return }

        let rounds = DebateRound.allCases
        guard let currentIndex = rounds.firstIndex(of: currentRound),
              currentIndex < rounds.count - 1 else {
            // Already at closing
            return
        }

        let nextRound = rounds[currentIndex + 1]
        self.currentRound = nextRound

        var updatedDebate = debate
        updatedDebate.currentRound = nextRound
        self.debate = updatedDebate
    }

    func reset() {
        state = .idle
        claimText = ""
        debate = nil
        currentRound = .opening
        isLoading = false
        evaluation = nil
        detectedFallacies = []
        fallacyReport = nil
        userTurnContent = ""
        aiTurnContent = ""
        errorMessage = nil
    }

    func analyzeClaim() {
        guard !claimText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Task {
            do {
                let report = try await fallacyService.generateFallacyReport(for: claimText)
                self.fallacyReport = report
                self.detectedFallacies = report.detectedFallacies
            } catch {
                self.errorMessage = "Analysis failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Helpers

    private func detectTopic(from input: String) -> String {
        let words = input.components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 && !$0.isWord() == false }
            .prefix(4)
        let topic = words.joined(separator: " ")
        return topic.isEmpty ? "Debate" : topic.capitalized
    }
}

// MARK: - View

struct MacAIDebateView: View {
    @StateObject private var viewModel = MacAIDebateViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()
                .background(MacTheme.divider)

            if viewModel.state == .idle {
                idleView
            } else {
                debateView
            }
        }
        .background(MacTheme.background)
        .frame(minWidth: 700, minHeight: 500)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Debate Intelligence")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                Text("4-round structured debate with fallacy detection")
                    .font(.system(size: 13))
                    .foregroundColor(MacTheme.secondaryText)
            }
            Spacer()

            if viewModel.state != .idle {
                Button {
                    viewModel.reset()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("New Debate")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(MacTheme.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(MacTheme.elevated)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    // MARK: - Idle State

    private var idleView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Input section
                claimInputSection

                // Fallacy analysis preview
                if !viewModel.detectedFallacies.isEmpty {
                    fallacyPreviewSection
                }

                // Start button
                startButton
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacTheme.background)
    }

    private var claimInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Claim")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.secondaryText)
                Spacer()
                Button {
                    viewModel.analyzeClaim()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars")
                        Text("Analyze")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.rebuttal)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.claimText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            TextEditor(text: $viewModel.claimText)
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(MacTheme.primaryText)
                .scrollContentBackground(.hidden)
                .background(MacTheme.surface)
                .frame(minHeight: 160)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: MacTheme.cornerRadius)
                        .stroke(MacTheme.divider, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.claimText.isEmpty {
                        Text("Enter a claim, belief, or argument you want to test through structured debate...")
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(MacTheme.secondaryText.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .onChange(of: viewModel.claimText) { _, _ in
                    // Auto-analyze on significant changes
                    if viewModel.claimText.count > 50 {
                        viewModel.analyzeClaim()
                    }
                }
        }
    }

    private var fallacyPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(MacTheme.challenge)
                Text("Pre-Debate Analysis")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
            }

            if let report = viewModel.fallacyReport {
                Text(report.overallAssessment)
                    .font(.system(size: 13))
                    .foregroundColor(MacTheme.secondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(report.summary.keys), id: \.self) { key in
                            if let type = FallacyType(rawValue: key) {
                                FallacyBadge(type: type, count: report.summary[key] ?? 0)
                            }
                        }
                    }
                }
            }
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }

    private var startButton: some View {
        HStack {
            Spacer()
            Button {
                viewModel.startDebate()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Begin Debate")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(viewModel.claimText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20 ? MacTheme.rebuttal : MacTheme.elevated)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.claimText.trimmingCharacters(in: .whitespacesAndNewlines).count < 20)
        }
    }

    // MARK: - Debate State

    private var debateView: some View {
        VStack(spacing: 0) {
            // Round indicator
            roundIndicator

            Divider()
                .background(MacTheme.divider)

            ScrollView {
                VStack(spacing: 20) {
                    // Claim summary
                    claimSummaryCard

                    // Detected fallacies
                    if !viewModel.detectedFallacies.isEmpty {
                        detectedFallaciesSection
                    }

                    // Turn history
                    debateTurnsSection

                    // Current round input
                    if viewModel.state == .debating {
                        roundInputSection
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(MacTheme.background)
    }

    private var roundIndicator: some View {
        HStack(spacing: 0) {
            ForEach(DebateRound.allCases, id: \.self) { round in
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(roundColor(for: round))
                            .frame(width: 24, height: 24)

                        if viewModel.currentRound == round {
                            Circle()
                                .stroke(MacTheme.rebuttal, lineWidth: 2)
                                .frame(width: 30, height: 30)
                        }

                        Text("\(round.index)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(round.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(viewModel.currentRound == round ? MacTheme.primaryText : MacTheme.secondaryText)
                        Text(round.description)
                            .font(.system(size: 10))
                            .foregroundColor(MacTheme.secondaryText.opacity(0.7))
                    }
                }

                if round != DebateRound.allCases.last {
                    Rectangle()
                        .fill(viewModel.currentRound.index > round.index ? MacTheme.success : MacTheme.divider)
                        .frame(width: 30, height: 2)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(MacTheme.surface)
    }

    private func roundColor(for round: DebateRound) -> Color {
        if viewModel.currentRound.index > round.index {
            return MacTheme.success
        } else if viewModel.currentRound == round {
            return MacTheme.rebuttal
        } else {
            return MacTheme.elevated
        }
    }

    private var claimSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("DEBATE TOPIC")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(MacTheme.secondaryText)
                Spacer()
                if let debate = viewModel.debate {
                    Text(debate.topic)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(MacTheme.rebuttal)
                }
            }

            if let debate = viewModel.debate {
                Text(debate.originalClaim)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(MacTheme.primaryText)
                    .lineSpacing(4)
            }
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }

    private var detectedFallaciesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(MacTheme.challenge)
                Text("Detected Fallacies (\(viewModel.detectedFallacies.count))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
            }

            ForEach(viewModel.detectedFallacies.prefix(5)) { fallacy in
                FallacyCard(fallacy: fallacy)
            }
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface.opacity(0.5))
        .cornerRadius(MacTheme.cornerRadius)
    }

    private var debateTurnsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(DebateRound.allCases.prefix(viewModel.currentRound.index), id: \.self) { round in
                let roundTurns = viewModel.debate?.turns.filter { $0.round == round } ?? []
                if !roundTurns.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Round \(round.index): \(round.rawValue)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(MacTheme.secondaryText)

                        ForEach(roundTurns) { turn in
                            DebateTurnCard(turn: turn)
                        }

                        if round != viewModel.currentRound {
                            Button {
                                viewModel.currentRound = round
                            } label: {
                                Text("Return to this round")
                                    .font(.system(size: 11))
                                    .foregroundColor(MacTheme.rebuttal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var roundInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your \(viewModel.currentRound.rawValue)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                Spacer()
                if let eval = viewModel.evaluation {
                    EvaluationBadge(evaluation: eval)
                }
            }

            TextEditor(text: $viewModel.userTurnContent)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(MacTheme.primaryText)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(12)
                .background(MacTheme.elevated)
                .cornerRadius(8)
                .overlay(alignment: .topLeading) {
                    if viewModel.userTurnContent.isEmpty {
                        Text(roundPlaceholder(for: viewModel.currentRound))
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(MacTheme.secondaryText.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }

            HStack {
                if viewModel.currentRound != .closing && viewModel.canAdvanceRound {
                    Button {
                        viewModel.advanceToNextRound()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle")
                            Text("Skip to \(nextRoundName)")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(MacTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    viewModel.submitUserResponse()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                        Text("Submit")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(viewModel.userTurnContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? MacTheme.elevated : MacTheme.rebuttal)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.userTurnContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }

            if viewModel.currentRound == .closing {
                closingSummarySection
            }
        }
        .padding(MacTheme.cardPadding)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }

    private var closingSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(MacTheme.success)
                Text("Debate Complete")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
            }

            if let debate = viewModel.debate {
                let closingTurn = debate.turns.last(where: { $0.round == .closing })
                if let turn = closingTurn {
                    Text(turn.content)
                        .font(.system(size: 13))
                        .foregroundColor(MacTheme.secondaryText)
                        .lineSpacing(3)
                }
            }

            HStack {
                Text("Total rounds: \(viewModel.debate?.turns.count ?? 0) turns")
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.secondaryText.opacity(0.7))
                Spacer()
            }
        }
    }

    private var nextRoundName: String {
        let rounds = DebateRound.allCases
        guard let idx = rounds.firstIndex(of: viewModel.currentRound),
              idx < rounds.count - 1 else { return "" }
        return rounds[idx + 1].rawValue
    }

    private func roundPlaceholder(for round: DebateRound) -> String {
        switch round {
        case .opening:
            return "Present your opening argument or claim..."
        case .rebuttal:
            return "Respond to the counter-arguments presented..."
        case .crossExamination:
            return "Answer the examination questions or pose your own..."
        case .closing:
            return "Provide your closing statement or summary..."
        }
    }
}

// MARK: - Supporting Views

struct DebateTurnCard: View {
    let turn: DebateTurn

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Speaker indicator
            VStack {
                Image(systemName: turn.speaker == .ai ? "cpu" : "person.fill")
                    .font(.system(size: 12))
                    .foregroundColor(turn.speaker == .ai ? MacTheme.rebuttal : MacTheme.success)
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(turn.speaker.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(turn.speaker == .ai ? MacTheme.rebuttal : MacTheme.success)

                    if turn.isAIGenerated {
                        Text("AI")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(MacTheme.secondaryText)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(MacTheme.elevated)
                            .cornerRadius(3)
                    }

                    Spacer()
                }

                Text(turn.content)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(MacTheme.primaryText)
                    .lineSpacing(3)
            }
        }
        .padding(12)
        .background(turn.speaker == .ai ? MacTheme.surface : MacTheme.elevated)
        .cornerRadius(8)
        .overlay(
            HStack {
                Rectangle()
                    .fill(turn.speaker == .ai ? MacTheme.rebuttal : MacTheme.success)
                    .frame(width: 3)
                Spacer()
            }
        )
    }
}

struct FallacyCard: View {
    let fallacy: DetectedFallacy

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: fallacy.fallacyType.icon)
                .font(.system(size: 12))
                .foregroundColor(MacTheme.challenge)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(fallacy.fallacyType.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(MacTheme.challenge)

                    Spacer()

                    SeverityIndicator(severity: fallacy.fallacyType.severity)
                }

                Text(fallacy.explanation)
                    .font(.system(size: 11))
                    .foregroundColor(MacTheme.secondaryText)
                    .lineSpacing(2)
            }
        }
        .padding(10)
        .background(MacTheme.elevated)
        .cornerRadius(6)
    }
}

struct FallacyBadge: View {
    let type: FallacyType
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 10))
            Text("\(type.rawValue) (\(count))")
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.15))
        .cornerRadius(4)
    }

    private var badgeColor: Color {
        switch type.severity {
        case 3: return MacTheme.challenge
        case 2: return Color.orange
        default: return Color.yellow
        }
    }
}

struct EvaluationBadge: View {
    let evaluation: DebateEvaluation

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(strengthColor)
                .frame(width: 8, height: 8)
            Text(evaluation.strength.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(strengthColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(strengthColor.opacity(0.15))
        .cornerRadius(4)
    }

    private var strengthColor: Color {
        switch evaluation.strength {
        case .strong: return MacTheme.success
        case .moderate: return Color.orange
        case .weak: return MacTheme.challenge
        }
    }
}

// MARK: - State

enum AIDebateState {
    case idle
    case starting
    case debating
    case submitting
    case complete
}

// MARK: - String Extension

extension String {
    func isWord() -> Bool {
        !self.filter { $0.isLetter || $0.isNumber }.isEmpty
    }
}

#Preview {
    MacAIDebateView()
        .frame(width: 800, height: 700)
}
