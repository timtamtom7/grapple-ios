import Foundation
import Combine

@MainActor
final class GrappleViewModel: ObservableObject {
    enum Phase: Equatable {
        case input
        case grappling
        case rebuttal
        case judgingRebuttals
        case synthesizing
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
            counterArguments = try await aiService.generateCounterArguments(for: inputText)

            // Initialize rebuttals
            rebuttals = counterArguments.map { Rebuttal(argumentId: $0.id) }

            phase = .rebuttal
        } catch {
            phase = .input
        }

        isLoading = false
    }

    func judgeRebuttal(at index: Int) async {
        guard index < rebuttals.count else { return }

        currentJudgmentIndex = index
        let judgment = try? await aiService.judgeRebuttal(
            rebuttals[index].text,
            against: counterArguments[index]
        )
        rebuttals[index].judgment = judgment ?? .weak
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
        }

        loadingMessage = "Synthesizing..."
        phase = .synthesizing

        synthesis = try? await aiService.generateSynthesis(
            input: inputText,
            arguments: counterArguments,
            rebuttals: rebuttals
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
            outcome: outcome
        )
        databaseService.saveSession(session)

        phase = .complete
        isLoading = false
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
    }
}
