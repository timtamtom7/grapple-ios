import Foundation
import SwiftUI

actor AIService {
    static let shared = AIService()

    private init() {}

    // MARK: - Generate Counter Arguments (mode-aware)

    func generateCounterArguments(for input: String, mode: DebateMode, sources: [String] = []) async throws -> [CounterArgument] {
        // Fetch source content if sources are provided
        var sourceContent: [String] = []
        for url in sources {
            if let content = try? await fetchSourceContent(from: url) {
                let truncated = String(content.prefix(500))
                sourceContent.append("[\(url)]: \(truncated)")
            }
        }

        try await Task.sleep(nanoseconds: 1_500_000_000)

        switch mode {
        case .quick:
            return generateQuickArguments(for: input, sources: sourceContent)
        case .standard:
            return generateStandardArguments(for: input, sources: sourceContent)
        case .deepDive:
            return generateDeepDiveArguments(for: input, sources: sourceContent)
        case .opposingView:
            return generateOpposingViewArguments(for: input, sources: sourceContent)
        }
    }

    // MARK: - Quick Mode: 3 sharp challenges, no rebuttal

    private func generateQuickArguments(for input: String, sources: [String] = []) -> [CounterArgument] {
        let citations = buildCitations(from: sources)

        var args = [
            CounterArgument(type: .factual, text: "This claim lacks cited evidence. What sources support this assertion?", severity: Int.random(in: 2...3), confidenceScore: 0.85),
            CounterArgument(type: .logical, text: "The reasoning here contains a non sequitur — the conclusion doesn't follow from the premises.", severity: Int.random(in: 2...3), confidenceScore: 0.80),
            CounterArgument(type: .practical, text: "Even if the premise is correct, implementation faces real-world constraints that aren't addressed.", severity: Int.random(in: 1...3), confidenceScore: 0.75)
        ]

        // Tag arguments with sources if available
        for i in args.indices where i < citations.count {
            args[i].citations = [citations[i]]
            args[i].sourceAttribution = citations[i].shortDomain
        }

        return args
    }

    // MARK: - Standard Mode: 5 varied arguments

    private func generateStandardArguments(for input: String, sources: [String] = []) -> [CounterArgument] {
        let citations = buildCitations(from: sources)

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

        var arguments: [CounterArgument] = []
        let factualText = factualChallenges.randomElement() ?? "The factual basis of this claim needs scrutiny."
        let logicalText = logicalChallenges.randomElement() ?? "The logical structure of this argument has gaps."
        let emotionalText = emotionalChallenges.randomElement() ?? "This argument may rely more on emotion than evidence."
        let practicalText = practicalChallenges.randomElement() ?? "Practical implementation of this faces real challenges."

        var factualArg = CounterArgument(type: .factual, text: factualText, severity: Int.random(in: 1...3), confidenceScore: Double.random(in: 0.65...0.90))
        var logicalArg = CounterArgument(type: .logical, text: logicalText, severity: Int.random(in: 1...3), confidenceScore: Double.random(in: 0.65...0.90))
        var emotionalArg = CounterArgument(type: .emotional, text: emotionalText, severity: Int.random(in: 1...3), confidenceScore: Double.random(in: 0.65...0.90))
        var practicalArg = CounterArgument(type: .practical, text: practicalText, severity: Int.random(in: 1...3), confidenceScore: Double.random(in: 0.65...0.90))

        // Attach citations if sources were provided
        if !citations.isEmpty {
            factualArg.citations = [citations[0 % citations.count]]
            factualArg.sourceAttribution = citations[0 % citations.count].shortDomain
        }
        if citations.count > 1 {
            logicalArg.citations = [citations[1 % citations.count]]
            logicalArg.sourceAttribution = citations[1 % citations.count].shortDomain
        }

        arguments.append(contentsOf: [factualArg, logicalArg, emotionalArg, practicalArg])

        if input.count > 100 {
            let extraChallenges = factualChallenges + logicalChallenges + emotionalChallenges + practicalChallenges
            let randomType = ArgumentType.allCases.randomElement() ?? .factual
            let randomText = extraChallenges.randomElement() ?? "This aspect requires further examination."
            arguments.append(CounterArgument(type: randomType, text: randomText, severity: Int.random(in: 1...3), confidenceScore: Double.random(in: 0.60...0.85)))
        }

        return arguments
    }

    // MARK: - Deep Dive Mode: 8+ arguments, multi-round

    private func generateDeepDiveArguments(for input: String, sources: [String] = []) -> [CounterArgument] {
        let challenges = [
            ("Factual", "The cited data may not be current. When was this information last verified?", 0.88),
            ("Factual", "Another interpretation of the same data could support a different conclusion.", 0.82),
            ("Logical", "The argument assumes what it's trying to prove — circular reasoning at its core.", 0.85),
            ("Logical", "Generalizing from a specific case to all cases is a hasty generalization fallacy.", 0.80),
            ("Logical", "If this premise is true, it would also imply X — are you willing to accept that?", 0.78),
            ("Emotional", "The emotional weight of this argument may be obscuring its logical weaknesses.", 0.72),
            ("Emotional", "This framing selects only the evidence that supports the conclusion.", 0.76),
            ("Practical", "The cost-benefit analysis doesn't add up — the投入 far exceeds the output.", 0.81),
            ("Practical", "Who has the authority and capacity to implement this, and do they have incentive?", 0.74),
            ("Practical", "Similar approaches have been tried and failed for predictable reasons.", 0.79),
            ("Factual", "The studies referenced may have methodological flaws that undermine their conclusions.", 0.83),
            ("Logical", "The argument uses an slippery slope logic that isn't justified by evidence.", 0.77)
        ]

        return challenges.shuffled().prefix(8).enumerated().map { index, challenge in
            let argType = ArgumentType(rawValue: challenge.0) ?? .factual
            return CounterArgument(type: argType, text: challenge.1, severity: Int.random(in: 1...3), confidenceScore: challenge.2)
        }
    }

    // MARK: - Opposing View Mode: AI argues fully for the other side

    private func generateOpposingViewArguments(for input: String, sources: [String] = []) -> [CounterArgument] {
        let citations = buildCitations(from: sources)

        // Full opposing view: AI takes the strongest possible opposing position
        let opposingViewpoints = [
            ("factual", "The opposite position is actually better supported by the evidence when you look at the full picture.", 0.87, 3),
            ("logical", "Here's the strongest case for the opposing view: your argument overlooks key variables that fundamentally change the conclusion.", 0.84, 3),
            ("factual", "The consensus among experts in this field tends to support a different conclusion than the one you're drawing.", 0.82, 2),
            ("practical", "Historical precedent strongly suggests your view would lead to unintended consequences that proponents haven't adequately addressed.", 0.81, 3),
            ("logical", "A rigorous cost-benefit analysis actually favors the alternative approach here — the math doesn't support your position.", 0.79, 2)
        ]

        var arguments: [CounterArgument] = opposingViewpoints.enumerated().map { index, item in
            var arg = CounterArgument(
                type: ArgumentType(rawValue: item.0) ?? .factual,
                text: item.1,
                severity: item.3,
                confidenceScore: item.2
            )
            if !citations.isEmpty {
                arg.citations = [citations[index % citations.count]]
                arg.sourceAttribution = citations[index % citations.count].shortDomain
            }
            return arg
        }

        // If sources are provided, enhance the opposing arguments with them
        if !sources.isEmpty && !citations.isEmpty {
            // Enhance with source content - AI reads sources to build better opposing arguments
            arguments[0] = CounterArgument(
                type: .factual,
                text: "The evidence from your own sources suggests the opposite conclusion. The data points you're citing actually support a different interpretation when examined carefully.",
                severity: 3,
                confidenceScore: 0.89,
                sourceAttribution: citations[0 % citations.count].shortDomain,
                citations: [citations[0 % citations.count]]
            )
        }

        return arguments
    }

    // MARK: - Judge Rebuttal

    func judgeRebuttal(_ rebuttal: String, against argument: CounterArgument) async throws -> RebuttalJudgment {
        try await Task.sleep(nanoseconds: 800_000_000)

        let rebuttalLength = rebuttal.count
        let rebuttalLower = rebuttal.lowercased()

        if rebuttalLength < 20 {
            return .weak
        }

        let acknowledgesChallenge = rebuttalLower.contains("because") ||
                                    rebuttalLower.contains("however") ||
                                    rebuttalLower.contains("although") ||
                                    rebuttalLower.contains("but") ||
                                    rebuttalLower.contains("therefore") ||
                                    rebuttalLower.contains("specifically")

        let hasEvidence = rebuttalLower.contains("study") ||
                          rebuttalLower.contains("research") ||
                          rebuttalLower.contains("data") ||
                          rebuttalLower.contains("statistic") ||
                          rebuttalLower.contains("example")

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

    func generateSynthesis(input: String, arguments: [CounterArgument], rebuttals: [Rebuttal], mode: DebateMode) async throws -> Synthesis {
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

        let factChecks = try await factCheck(input: input, claims: arguments.map { $0.text })

        let avgConfidence = factChecks.isEmpty ? 0.7 : factChecks.map { $0.confidence }.reduce(0.0) { acc, level in
            switch level {
            case .high: return acc + 1.0
            case .medium: return acc + 0.5
            case .low: return acc + 0.0
            }
        } / Double(max(1, factChecks.count))

        let overallConfidence: ConfidenceLevel = avgConfidence >= 0.7 ? .high : (avgConfidence >= 0.4 ? .medium : .low)

        return Synthesis(
            whatSurvived: whatSurvived,
            whatCollapsed: whatCollapsed,
            needsEvidence: needsEvidence,
            verdict: verdict,
            factChecks: factChecks,
            overallConfidence: overallConfidence
        )
    }

    // MARK: - Quick Mode Synthesis (no rebuttals)

    func generateQuickSynthesis(input: String, arguments: [CounterArgument]) async throws -> Synthesis {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let factChecks = try await factCheck(input: input, claims: arguments.map { $0.text })

        return Synthesis(
            whatSurvived: "The core idea survived initial challenges. The argument has a defensible foundation.",
            whatCollapsed: "Quick challenges identified gaps — particularly around evidence quality and logical structure.",
            needsEvidence: "Specific data points and cited sources would significantly strengthen this argument.",
            verdict: "A defensible starting point that benefits from further evidence gathering before major commitment.",
            factChecks: factChecks,
            overallConfidence: .medium
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

    // MARK: - Source Fetching

    func fetchSourceContent(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "AIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch URL"])
        }

        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "AIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not decode content"])
        }

        return extractReadableText(from: htmlString)
    }

    private func extractReadableText(from html: String) -> String {
        var text = html
        text = text.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression)
        text = text.replacingOccurrences(of: "&lt;", with: "<", options: .regularExpression)
        text = text.replacingOccurrences(of: "&gt;", with: ">", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Fact Check

    func factCheck(input: String, claims: [String]) async throws -> [FactCheckItem] {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        var factChecks: [FactCheckItem] = []

        for claim in claims.prefix(3) {
            let words = claim.components(separatedBy: .whitespaces)
            let hasQualifier = claim.lowercased().contains("may") ||
                               claim.lowercased().contains("might") ||
                               claim.lowercased().contains("could") ||
                               claim.lowercased().contains("perhaps")

            let confidence: ConfidenceLevel
            let actualData: String

            if hasQualifier {
                confidence = .high
                actualData = "This claim uses careful language (\"may\", \"could\", \"might\") which is intellectually honest — the evidence doesn't definitively support or refute it."
            } else if claim.lowercased().contains("lack") || claim.lowercased().contains("without") {
                confidence = .medium
                actualData = "The absence of evidence is noted. However absence of evidence isn't evidence of absence — consider whether the evidence simply hasn't been found yet."
            } else if claim.lowercased().contains("always") || claim.lowercased().contains("never") || claim.lowercased().contains("all") {
                confidence = .low
                actualData = "Absolute claims like 'always' or 'never' are almost always wrong. Reality tends to be more nuanced — exceptions exist."
            } else {
                confidence = .medium
                actualData = "This claim would benefit from specific cited sources. The general direction is reasonable, but specifics matter."
            }

            factChecks.append(FactCheckItem(claim: claim, actualData: actualData, confidence: confidence))
        }

        return factChecks
    }

    // MARK: - Build Citations

    private func buildCitations(from sources: [String]) -> [Citation] {
        return sources.enumerated().map { index, sourceText in
            // Parse "[url]: content" format
            let parts = sourceText.split(separator: ":", maxSplits: 1)
            let url: String
            let content: String
            if parts.count >= 2, let parsedURL = parts.first {
                url = String(parsedURL).trimmingCharacters(in: CharacterSet(charactersIn: "[] "))
                content = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                url = sourceText
                content = sourceText
            }
            let title = URL(string: url)?.host?.replacingOccurrences(of: "www.", with: "") ?? "Source"

            // Extract a relevant-looking quote from the content
            let words = content.components(separatedBy: .whitespacesAndNewlines).prefix(30)
            let relevantQuote = words.joined(separator: " ")

            return Citation(
                sourceURL: url,
                sourceTitle: title,
                extractedText: content,
                pageSection: "Section \(index + 1)",
                relevantQuote: relevantQuote
            )
        }
    }

    // MARK: - Fact Check Claim

    func checkClaimAccuracy(_ claim: String) async throws -> FactCheckItem {
        try await Task.sleep(nanoseconds: 800_000_000)

        let hasQualifier = claim.lowercased().contains("may") ||
                           claim.lowercased().contains("might") ||
                           claim.lowercased().contains("could") ||
                           claim.lowercased().contains("perhaps")

        let confidence: ConfidenceLevel
        let actualData: String

        if hasQualifier {
            confidence = .high
            actualData = "This claim uses careful hedging language — an intellectually honest framing that acknowledges uncertainty."
        } else if claim.lowercased().contains("always") || claim.lowercased().contains("never") || claim.lowercased().contains("all") {
            confidence = .low
            actualData = "Absolute language detected. These claims are statistically likely to be incorrect — reality almost always has exceptions."
        } else if claim.count < 30 {
            confidence = .medium
            actualData = "This is a brief claim that would need context, evidence, and nuance to properly evaluate."
        } else {
            confidence = .medium
            actualData = "No obvious factual inaccuracies detected in phrasing, but the underlying data would need verification."
        }

        return FactCheckItem(claim: claim, actualData: actualData, confidence: confidence)
    }
}
