import Foundation

actor AIService {
    static let shared = AIService()

    private init() {}

    // MARK: - Generate Counter Arguments

    func generateCounterArguments(for input: String) async throws -> [CounterArgument] {
        // Simulated AI response for Round 1 — in production, this would call
        // Apple Intelligence via AppIntents or AppleScript bridge

        // For Round 1, we generate realistic counter-arguments based on input analysis
        let arguments = generateArgumentsForInput(input)

        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        return arguments
    }

    private func generateArgumentsForInput(_ input: String) -> [CounterArgument] {
        let lowercased = input.lowercased()

        // Detect potential argument types based on keywords
        var types: [ArgumentType] = [.factual, .logical, .emotional, .practical]

        var arguments: [CounterArgument] = []

        // Always include at least 4 types
        let factualChallenges = [
            "This claim lacks cited sources. The statistics referenced appear unsubstantiated.",
            "The premise assumes a correlation that hasn't been established as causation.",
            "Historical precedents cited may not apply directly to the current context.",
            "The data being referenced may be outdated or misrepresented."
        ]

        let logicalChallenges = [
            "The reasoning contains a hidden assumption that undermines the conclusion.",
            "This argument could lead to contradictory conclusions when applied consistently.",
            "The logical structure relies on an either/or false dichotomy.",
            "The chain of reasoning has a gap between premise and conclusion."
        ]

        let emotionalChallenges = [
            "This argument may be relying on fear or anxiety rather than evidence.",
            "The framing appeals to identity or tribe rather than merit.",
            "Confirmation bias may be shaping how evidence is being interpreted.",
            "The urgency implied may not be warranted by the actual evidence."
        ]

        let practicalChallenges = [
            "In practice, this faces significant implementation barriers.",
            "The resources required may not be available or feasible.",
            "Unintended consequences of this approach have not been considered.",
            "This solution may not scale or adapt to changing conditions."
        ]

        // Build arguments ensuring variety
        arguments.append(CounterArgument(type: .factual, text: factualChallenges.randomElement()!, severity: Int.random(in: 1...3)))
        arguments.append(CounterArgument(type: .logical, text: logicalChallenges.randomElement()!, severity: Int.random(in: 1...3)))
        arguments.append(CounterArgument(type: .emotional, text: emotionalChallenges.randomElement()!, severity: Int.random(in: 1...3)))
        arguments.append(CounterArgument(type: .practical, text: practicalChallenges.randomElement()!, severity: Int.random(in: 1...3)))

        // Add a 5th if input is long enough
        if input.count > 100 {
            let extraChallenges = factualChallenges + logicalChallenges + emotionalChallenges + practicalChallenges
            arguments.append(CounterArgument(type: types.randomElement()!, text: extraChallenges.randomElement()!, severity: Int.random(in: 1...3)))
        }

        return arguments
    }

    // MARK: - Judge Rebuttal

    func judgeRebuttal(_ rebuttal: String, against argument: CounterArgument) async throws -> RebuttalJudgment {
        // Simulate AI judgment
        try await Task.sleep(nanoseconds: 800_000_000)

        let rebuttalLength = rebuttal.count
        let rebuttalLower = rebuttal.lowercased()

        // Simple heuristic for Round 1
        if rebuttalLength < 20 {
            return .weak
        }

        // Check for acknowledgment of the challenge
        let acknowledgesChallenge = rebuttalLower.contains("because") ||
                                    rebuttalLower.contains("however") ||
                                    rebuttalLower.contains("although") ||
                                    rebuttalLower.contains("but") ||
                                    rebuttalLower.contains("therefore") ||
                                    rebuttalLower.contains("specifically")

        // Check for evidence or logic language
        let hasEvidence = rebuttalLower.contains("study") ||
                          rebuttalLower.contains("research") ||
                          rebuttalLower.contains("data") ||
                          rebuttalLower.contains("statistic") ||
                          rebuttalLower.contains("example")

        // Check for counter-point
        let hasCounter = rebuttalLower.contains("instead") ||
                         rebuttalLower.contains("rather") ||
                         rebuttalLower.contains("alternative") ||
                         rebuttalLower.contains("on the contrary")

        if acknowledgesChallenge && hasEvidence && hasCounter && rebuttalLength > 80 {
            return .strong
        } else if acknowledgesChallenge && rebuttalLength > 40 {
            return .partial
        } else {
            return .weak
        }
    }

    // MARK: - Generate Synthesis

    func generateSynthesis(input: String, arguments: [CounterArgument], rebuttals: [Rebuttal]) async throws -> Synthesis {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        let strongCount = rebuttals.filter { $0.judgment == .strong }.count
        let partialCount = rebuttals.filter { $0.judgment == .partial }.count
        let weakCount = rebuttals.filter { $0.judgment == .weak }.count

        var whatSurvived: String
        var whatCollapsed: String
        var needsEvidence: String
        var verdict: String

        if strongCount >= 3 {
            whatSurvived = "Your core argument held firm against factual, logical, emotional, and practical challenges. Your reasoning was well-structured and you effectively defended key claims with evidence and counter-points."
            whatCollapsed = "Minor gaps in practical implementation were identified. Some emotional framing could be tightened."
            needsEvidence = "Consider adding specific data points or case studies to further strengthen the practical aspects."
            verdict = "A robust argument that survives rigorous scrutiny. Ready for real-world testing with minor refinements."
        } else if strongCount + partialCount >= 3 {
            whatSurvived = "The main thesis survived, though with some strain. You acknowledged challenges and provided partial defenses."
            whatCollapsed = "Several challenges went unanswered or poorly addressed, particularly around \(arguments.last?.type.rawValue.lowercased() ?? "supporting evidence")."
            needsEvidence = "The argument would benefit from additional evidence, particularly studies or data that address the factual challenges raised."
            verdict = "A promising argument with a solid foundation, but needs more evidence to be bulletproof."
        } else {
            whatSurvived = "A few rebuttals showed promise, particularly your response to the \(arguments.first?.type.rawValue.lowercased() ?? "initial") challenge."
            whatCollapsed = "Multiple challenges went undefended. The argument as currently constructed does not hold up well under pressure."
            needsEvidence = "The fundamental claims need empirical support. Without data or concrete examples, the argument relies too heavily on assertion."
            verdict = "The argument needs significant work before it can withstand serious scrutiny. Consider rebuilding from stronger evidence."
        }

        return Synthesis(
            whatSurvived: whatSurvived,
            whatCollapsed: whatCollapsed,
            needsEvidence: needsEvidence,
            verdict: verdict
        )
    }

    // MARK: - Detect Topic

    func detectTopic(from input: String) async -> String {
        let words = input.components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
            .prefix(5)

        let topic = words.joined(separator: " ").trimmingCharacters(in: .punctuationCharacters)
        return topic.isEmpty ? "Untitled Session" : topic.capitalized
    }
}
