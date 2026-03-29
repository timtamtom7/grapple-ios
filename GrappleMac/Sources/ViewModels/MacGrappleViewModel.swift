import Foundation
import Combine

enum GrappleState {
    case idle
    case grappling
    case rebutting
    case synthesizing
    case done
}

@MainActor
class MacGrappleViewModel: ObservableObject {
    @Published var state: GrappleState = .idle
    @Published var originalInput: String = ""
    @Published var counterArguments: [CounterArgument] = []
    @Published var rebuttalTexts: [UUID: String] = [:]
    @Published var rebuttalJudgments: [UUID: RebuttalJudgment] = [:]
    @Published var synthesis: Synthesis?
    @Published var session: GrappleSession?
    @Published var isLoading: Bool = false

    private var aiService: AIService?
    private var dbService: DatabaseService?
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupServices()
    }

    private func setupServices() {
        dbService = DatabaseService.shared
        aiService = AIService.shared
    }

    @MainActor
    func startGrapple(with input: String) {
        originalInput = input
        state = .grappling
        isLoading = true

        Task {
            do {
                let arguments = try await aiService?.generateCounterArguments(
                    for: input,
                    mode: .standard,
                    sources: []
                ) ?? generateMockArguments(for: input)
                counterArguments = arguments
            } catch {
                counterArguments = generateMockArguments(for: input)
            }
            isLoading = false
        }
    }

    func proceedToRebuttals() {
        state = .rebutting
    }

    @MainActor
    func submitRebuttals() {
        state = .synthesizing
        isLoading = true

        Task {
            // Judge each rebuttal
            for argument in counterArguments {
                if let text = rebuttalTexts[argument.id], !text.isEmpty {
                    do {
                        let judgment = try await aiService?.judgeRebuttal(text, against: argument)
                        rebuttalJudgments[argument.id] = judgment ?? judgeMockRebuttal(argument: argument, rebuttal: text)
                    } catch {
                        rebuttalJudgments[argument.id] = judgeMockRebuttal(argument: argument, rebuttal: text)
                    }
                }
            }

            // Generate synthesis
            let rebuttals = buildRebuttals()
            do {
                let synth = try await aiService?.generateSynthesis(
                    input: originalInput,
                    arguments: counterArguments,
                    rebuttals: rebuttals,
                    mode: .standard
                )
                synthesis = synth
                session = buildSession(with: synth ?? generateMockSynthesis())
            } catch {
                synthesis = generateMockSynthesis()
                session = buildSession(with: synthesis!)
            }

            if let session = session {
                dbService?.saveSession(session)
            }

            isLoading = false
            state = .done
        }
    }

    func reset() {
        state = .idle
        originalInput = ""
        counterArguments = []
        rebuttalTexts = [:]
        rebuttalJudgments = [:]
        synthesis = nil
        session = nil
    }

    // MARK: - Helpers

    private func detectTopic(from input: String) -> String {
        let words = input.split(separator: " ")
        let significant = words.prefix(5).map(String.init)
        return significant.joined(separator: " ").capitalized
    }

    private func buildRebuttals() -> [Rebuttal] {
        counterArguments.compactMap { arg in
            guard let text = rebuttalTexts[arg.id], !text.isEmpty else { return nil }
            return Rebuttal(
                id: UUID(),
                argumentId: arg.id,
                text: text,
                judgment: rebuttalJudgments[arg.id] ?? .partial
            )
        }
    }

    private func buildSession(with synth: Synthesis) -> GrappleSession {
        let rebuttals = buildRebuttals()
        let strongCount = rebuttalJudgments.values.filter { $0 == .strong }.count
        let totalCount = rebuttalJudgments.count
        let ratio = totalCount > 0 ? Double(strongCount) / Double(totalCount) : 0.5

        let outcome: SessionOutcome
        if ratio >= 0.7 { outcome = .strong }
        else if ratio >= 0.4 { outcome = .mixed }
        else { outcome = .weak }

        return GrappleSession(
            topic: detectTopic(from: originalInput),
            originalInput: originalInput,
            counterArguments: counterArguments,
            rebuttals: rebuttals,
            synthesis: synth,
            outcome: outcome,
            debateMode: .standard
        )
    }

    // MARK: - Mock data for development

    private func generateMockArguments(for input: String) -> [CounterArgument] {
        return [
            CounterArgument(type: .factual, text: "Your claim contains a factual assumption that may not hold up under scrutiny. The data you cited comes from a single source with known methodology issues.", severity: 2),
            CounterArgument(type: .logical, text: "There's a logical gap in your reasoning chain. You assume X implies Y, but Y could equally result from Z or W without X being necessary.", severity: 3),
            CounterArgument(type: .practical, text: "Even if your argument is theoretically sound, real-world implementation faces significant friction. Historical precedent suggests adoption rates will be lower than expected.", severity: 2),
            CounterArgument(type: .emotional, text: "Your framing relies heavily on an emotional appeal that could cloud judgment. Consider whether the same conclusion holds with purely rational framing.", severity: 1),
            CounterArgument(type: .logical, text: "You're arguing from a correlation-causation fallacy. The two phenomena may be related without one causing the other.", severity: 2)
        ]
    }

    private func judgeMockRebuttal(argument: CounterArgument, rebuttal: String) -> RebuttalJudgment {
        let wordCount = rebuttal.split(separator: " ").count
        if wordCount < 20 { return .weak }
        if wordCount < 50 { return .partial }
        return .strong
    }

    private func generateMockSynthesis() -> Synthesis {
        return Synthesis(
            whatSurvived: "Your core argument about X holds up reasonably well. The evidence for the primary claim is solid, and alternative explanations don't fully account for the observed data.",
            whatCollapsed: "The practical implementation argument fell apart under pressure. The timeline you proposed is unrealistic given institutional constraints, and historical precedent contradicts your optimism.",
            needsEvidence: "The causal mechanism remains unproven. You need stronger empirical evidence linking cause and effect, ideally from a controlled study or natural experiment.",
            verdict: "Your thinking is directionally sound but needs more empirical grounding. Strengthen the causal argument before proceeding."
        )
    }
}
