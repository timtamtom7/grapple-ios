import Foundation
import Combine

@MainActor
final class GrappleViewModel: ObservableObject {
    enum Phase: Equatable {
        case input
        case grappling
        case arguments   // showing counter-arguments
        case rebuttal
        case judgingRebuttals
        case synthesizing
        case quickComplete
        case complete
    }

    @Published var phase: Phase = .input
    @Published var inputText: String = ""
    @Published var topic: String = ""
    @Published var counterArguments: [CounterArgument] = []
    @Published var rebuttals: [Rebuttal] = []
    @Published var synthesis: Synthesis?
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String = "Grappling..."
    @Published var currentJudgmentIndex: Int? = nil
    @Published var debateMode: DebateMode = .standard
    @Published var sourceURLs: [String] = []
    @Published var sourceInputText: String = ""
    @Published var isLoadingSources: Bool = false
    @Published var sessionToReopen: GrappleSession?

    private let aiService = AIService.shared
    private let databaseService = DatabaseService.shared

    var canStartGrapple: Bool {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    var rebuttalsEntered: Int {
        rebuttals.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }

    func startGrapple() async {
        guard canStartGrapple else { return }

        isLoading = true
        loadingMessage = "Detecting topic..."
        phase = .grappling

        topic = await aiService.detectTopic(from: inputText)

        loadingMessage = "Finding counter-arguments..."
        do {
            counterArguments = try await aiService.generateCounterArguments(
                for: inputText,
                mode: debateMode,
                sources: sourceURLs
            )

            if debateMode.hasRebuttal {
                rebuttals = counterArguments.map { Rebuttal(argumentId: $0.id) }
                phase = .arguments  // Show counter-arguments first
            } else {
                // Quick mode — go straight to synthesis
                loadingMessage = "Generating synthesis..."
                phase = .synthesizing
                synthesis = try? await aiService.generateQuickSynthesis(input: inputText, arguments: counterArguments)

                let strongCount = counterArguments.filter { $0.confidenceScore >= 0.8 }.count
                let weakCount = counterArguments.filter { $0.confidenceScore < 0.6 }.count

                let outcome: SessionOutcome
                if strongCount >= 2 { outcome = .strong }
                else if weakCount >= 2 { outcome = .weak }
                else { outcome = .mixed }

                let session = GrappleSession(
                    topic: topic,
                    originalInput: inputText,
                    counterArguments: counterArguments,
                    rebuttals: [],
                    synthesis: synthesis,
                    outcome: outcome,
                    debateMode: debateMode,
                    sourceURLs: sourceURLs,
                    factChecks: synthesis?.factChecks ?? []
                )
                databaseService.saveSession(session)

                phase = .quickComplete
            }
        } catch {
            phase = .input
        }

        isLoading = false
    }

    func proceedToRebuttal() {
        phase = .rebuttal
    }

    func judgeRebuttal(at index: Int) async {
        guard index < rebuttals.count else { return }

        currentJudgmentIndex = index
        let judgment = try? await aiService.judgeRebuttal(
            rebuttals[index].text,
            against: counterArguments[index]
        )
        rebuttals[index].judgment = judgment ?? .weak

        switch rebuttals[index].judgment {
        case .strong: rebuttals[index].confidenceLevel = .high
        case .partial: rebuttals[index].confidenceLevel = .medium
        case .weak: rebuttals[index].confidenceLevel = .low
        }

        currentJudgmentIndex = nil
    }

    func submitRebuttals() async {
        isLoading = true
        loadingMessage = "Judging rebuttals..."
        phase = .judgingRebuttals

        for i in rebuttals.indices {
            let judgment = try? await aiService.judgeRebuttal(
                rebuttals[i].text,
                against: counterArguments[i]
            )
            rebuttals[i].judgment = judgment ?? .weak

            switch rebuttals[i].judgment {
            case .strong: rebuttals[i].confidenceLevel = .high
            case .partial: rebuttals[i].confidenceLevel = .medium
            case .weak: rebuttals[i].confidenceLevel = .low
            }
        }

        loadingMessage = "Synthesizing..."
        phase = .synthesizing

        synthesis = try? await aiService.generateSynthesis(
            input: inputText,
            arguments: counterArguments,
            rebuttals: rebuttals,
            mode: debateMode
        )

        // Determine outcome
        let strongCount = rebuttals.filter { $0.judgment == .strong }.count
        let weakCount = rebuttals.filter { $0.judgment == .weak }.count

        let outcome: SessionOutcome
        if strongCount >= 3 {
            outcome = .strong
        } else if weakCount >= 3 {
            outcome = .weak
        } else {
            outcome = .mixed
        }

        // Save session
        let session = GrappleSession(
            topic: topic,
            originalInput: inputText,
            counterArguments: counterArguments,
            rebuttals: rebuttals,
            synthesis: synthesis,
            outcome: outcome,
            debateMode: debateMode,
            sourceURLs: sourceURLs,
            factChecks: synthesis?.factChecks ?? []
        )
        databaseService.saveSession(session)

        phase = .complete
        isLoading = false
    }

    func checkClaimAccuracy(_ claim: String) async -> FactCheckItem? {
        return try? await aiService.checkClaimAccuracy(claim)
    }

    func reopenSession(_ session: GrappleSession) {
        sessionToReopen = session
        inputText = session.originalInput
        topic = session.topic
        debateMode = session.debateMode
        sourceURLs = session.sourceURLs
        counterArguments = session.counterArguments
        rebuttals = session.rebuttals
        synthesis = session.synthesis
        phase = session.debateMode.hasRebuttal ? .rebuttal : .quickComplete
    }

    func reset() {
        phase = .input
        inputText = ""
        topic = ""
        counterArguments = []
        rebuttals = []
        synthesis = nil
        isLoading = false
        currentJudgmentIndex = nil
        debateMode = .standard
        sourceURLs = []
        sourceInputText = ""
        isLoadingSources = false
        sessionToReopen = nil
    }
}
