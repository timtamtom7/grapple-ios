import Foundation

// ============================================================
// MARK: - Debate Types (shared across services)
// ============================================================

/// Represents a challenge to an underlying assumption in an argument
struct Challenge: Identifiable, Codable, Equatable {
    let id: UUID
    let assumption: String
    let text: String
    let type: FallacyType?
    let strength: Int // 1-3

    init(
        id: UUID = UUID(),
        assumption: String,
        text: String,
        type: FallacyType? = nil,
        strength: Int = 2
    ) {
        self.id = id
        self.assumption = assumption
        self.text = text
        self.type = type
        self.strength = max(1, min(3, strength))
    }
}

/// Logical fallacy types
enum FallacyType: String, Codable, CaseIterable, Hashable {
    case strawMan = "Straw Man"
    case adHominem = "Ad Hominem"
    case falseDichotomy = "False Dichotomy"
    case appealToAuthority = "Appeal to Authority"
    case slipperySlope = "Slippery Slope"
    case circularReasoning = "Circular Reasoning"
    case hastyGeneralization = "Hasty Generalization"
    case redHerring = "Red Herring"
    case appealToEmotion = "Appeal to Emotion"
    case falseCausality = "False Causality"

    var description: String {
        switch self {
        case .strawMan: return "Misrepresenting an argument to make it easier to attack"
        case .adHominem: return "Attacking the person rather than the argument"
        case .falseDichotomy: return "Presenting only two options when more exist"
        case .appealToAuthority: return "Using authority as evidence without justification"
        case .slipperySlope: return "Claiming one event leads to a chain of negative events without evidence"
        case .circularReasoning: return "Using the conclusion as a premise"
        case .hastyGeneralization: return "Drawing broad conclusions from limited evidence"
        case .redHerring: return "Introducing an irrelevant topic to divert attention"
        case .appealToEmotion: return "Using emotion rather than evidence to persuade"
        case .falseCausality: return "Assuming cause-and-effect without sufficient evidence"
        }
    }

    var icon: String {
        switch self {
        case .strawMan: return "figure.stand"
        case .adHominem: return "person.fill.xmark"
        case .falseDichotomy: return "arrow.triangle.branch"
        case .appealToAuthority: return "crown.fill"
        case .slipperySlope: return "arrow.down.right.circle"
        case .circularReasoning: return "arrow.turn.up.right"
        case .hastyGeneralization: return "square.stack.3d.up.slash"
        case .redHerring: return "fish.fill"
        case .appealToEmotion: return "heart.fill"
        case .falseCausality: return "arrow.triangle.swap"
        }
    }

    var severity: Int {
        switch self {
        case .circularReasoning, .strawMan, .falseDichotomy: return 3
        case .slipperySlope, .adHominem, .falseCausality: return 2
        case .hastyGeneralization, .redHerring, .appealToEmotion, .appealToAuthority: return 1
        }
    }
}

/// A round in a structured debate
enum DebateRound: String, CaseIterable, Codable, Hashable {
    case opening = "Opening"
    case rebuttal = "Rebuttal"
    case crossExamination = "Cross-Examination"
    case closing = "Closing"

    var index: Int {
        switch self {
        case .opening: return 1
        case .rebuttal: return 2
        case .crossExamination: return 3
        case .closing: return 4
        }
    }

    var description: String {
        switch self {
        case .opening: return "Present your initial argument"
        case .rebuttal: return "Respond to the counter-arguments"
        case .crossExamination: return "Probe weaknesses in opposing reasoning"
        case .closing: return "Synthesize and conclude"
        }
    }

    var icon: String {
        switch self {
        case .opening: return "text.alignleft"
        case .rebuttal: return "arrow.left.arrow.right"
        case .crossExamination: return "questionmark.circle"
        case .closing: return "checkmark.seal"
        }
    }
}

/// A single turn in a debate round
struct DebateTurn: Identifiable, Codable {
    let id: UUID
    let round: DebateRound
    let speaker: DebateSpeaker
    let content: String
    let timestamp: Date
    var isAIGenerated: Bool

    init(
        id: UUID = UUID(),
        round: DebateRound,
        speaker: DebateSpeaker,
        content: String,
        timestamp: Date = Date(),
        isAIGenerated: Bool = false
    ) {
        self.id = id
        self.round = round
        self.speaker = speaker
        self.content = content
        self.timestamp = timestamp
        self.isAIGenerated = isAIGenerated
    }
}

enum DebateSpeaker: String, Codable {
    case user = "You"
    case ai = "AI"
    case system = "System"
}

/// A complete structured debate session
struct AIDebate: Identifiable, Codable {
    let id: UUID
    var topic: String
    var originalClaim: String
    var currentRound: DebateRound
    var turns: [DebateTurn]
    var detectedFallacies: [DetectedFallacy]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        topic: String,
        originalClaim: String,
        currentRound: DebateRound = .opening,
        turns: [DebateTurn] = [],
        detectedFallacies: [DetectedFallacy] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.topic = topic
        self.originalClaim = originalClaim
        self.currentRound = currentRound
        self.turns = turns
        self.detectedFallacies = detectedFallacies
        self.createdAt = createdAt
    }

    var isComplete: Bool {
        currentRound == .closing && !turns.isEmpty
    }
}

/// A fallacy detected in a piece of text
struct DetectedFallacy: Identifiable, Codable, Equatable {
    let id: UUID
    let fallacyType: FallacyType
    let excerpt: String
    let explanation: String
    let positionStart: Int
    let positionEnd: Int

    init(
        id: UUID = UUID(),
        fallacyType: FallacyType,
        excerpt: String,
        explanation: String,
        positionStart: Int = 0,
        positionEnd: Int = 0
    ) {
        self.id = id
        self.fallacyType = fallacyType
        self.excerpt = excerpt
        self.explanation = explanation
        self.positionStart = positionStart
        self.positionEnd = positionEnd
    }
}

enum DebateStrength: String, Codable {
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"
}

struct DebateEvaluation: Identifiable, Codable {
    let id: UUID
    let turnId: UUID
    let score: Double
    let strength: DebateStrength
    let detectedFallacies: [DetectedFallacy]
    let feedback: String

    init(
        id: UUID = UUID(),
        turnId: UUID,
        score: Double,
        strength: DebateStrength,
        detectedFallacies: [DetectedFallacy] = [],
        feedback: String
    ) {
        self.id = id
        self.turnId = turnId
        self.score = score
        self.strength = strength
        self.detectedFallacies = detectedFallacies
        self.feedback = feedback
    }
}

struct FallacyReport: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let detectedFallacies: [DetectedFallacy]
    let summary: [String: Int]
    let overallAssessment: String

    init(
        id: UUID = UUID(),
        originalText: String,
        detectedFallacies: [DetectedFallacy],
        summary: [String: Int],
        overallAssessment: String
    ) {
        self.id = id
        self.originalText = originalText
        self.detectedFallacies = detectedFallacies
        self.summary = summary
        self.overallAssessment = overallAssessment
    }

    var fallacyCount: Int { detectedFallacies.count }

    var severityScore: Int {
        detectedFallacies.reduce(0) { $0 + $1.fallacyType.severity }
    }

    var isClean: Bool { detectedFallacies.isEmpty }
}

// ============================================================
// MARK: - AI Debate Service
// ============================================================

actor AIDebateService {
    static let shared = AIDebateService()

    private init() {}

    // MARK: - Generate Counter Arguments

    func generateCounterArguments(to claim: String) async throws -> [CounterArgument] {
        try await Task.sleep(nanoseconds: 1_500_000_000)

        let fallacyService = FallacyDetectionService.shared
        let fallacies = try await fallacyService.detectFallacies(in: claim)

        var arguments: [CounterArgument] = []

        for fallacy in fallacies {
            let argType: ArgumentType
            switch fallacy.fallacyType {
            case .strawMan, .circularReasoning, .falseDichotomy, .hastyGeneralization:
                argType = .logical
            case .adHominem, .appealToEmotion, .redHerring:
                argType = .emotional
            case .appealToAuthority, .falseCausality:
                argType = .factual
            case .slipperySlope:
                argType = .practical
            }

            arguments.append(CounterArgument(
                type: argType,
                text: fallacy.explanation,
                severity: fallacy.fallacyType.severity,
                confidenceScore: 0.82
            ))
        }

        if arguments.isEmpty {
            arguments = generateStandardChallenges(for: claim)
        }

        return arguments
    }

    // MARK: - Challenge Assumptions

    func challengeAssumptions(in claim: String) async throws -> [Challenge] {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        let fallacyService = FallacyDetectionService.shared
        let fallacies = try await fallacyService.detectFallacies(in: claim)

        var challenges: [Challenge] = []

        for fallacy in fallacies {
            challenges.append(Challenge(
                assumption: extractAssumption(from: claim, fallacy: fallacy),
                text: "This argument contains a \(fallacy.fallacyType.rawValue) fallacy: \(fallacy.explanation)",
                type: fallacy.fallacyType,
                strength: fallacy.fallacyType.severity
            ))
        }

        let generalChallenges = generateGeneralAssumptionChallenges(for: claim)
        challenges.append(contentsOf: generalChallenges)

        return challenges
    }

    // MARK: - Structured Debate

    func generateOpening(for claim: String, speaker: DebateSpeaker) async throws -> DebateTurn {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let content: String
        if speaker == .user {
            content = claim
        } else {
            content = generateAIOpening(for: claim)
        }

        return DebateTurn(
            round: .opening,
            speaker: speaker,
            content: content,
            isAIGenerated: speaker == .ai
        )
    }

    func generateRebuttal(for claim: String, opposingArgument: String) async throws -> DebateTurn {
        try await Task.sleep(nanoseconds: 1_200_000_000)

        let fallacyService = FallacyDetectionService.shared
        let fallacies = try await fallacyService.detectFallacies(in: opposingArgument)

        var rebuttalText = "I challenge this position on the following grounds:\n\n"

        if !fallacies.isEmpty {
            rebuttalText += "Logical fallacies detected:\n"
            for fallacy in fallacies {
                rebuttalText += "• \(fallacy.fallacyType.rawValue): \(fallacy.explanation)\n"
            }
        }

        rebuttalText += "\n\(generateCounterArgumentText(against: opposingArgument))"

        return DebateTurn(
            round: .rebuttal,
            speaker: .ai,
            content: rebuttalText,
            isAIGenerated: true
        )
    }

    func generateCrossExamination(for claim: String, previousTurn: DebateTurn) async throws -> DebateTurn {
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let questions = generateCrossExaminationQuestions()

        return DebateTurn(
            round: .crossExamination,
            speaker: .ai,
            content: questions,
            isAIGenerated: true
        )
    }

    func generateClosing(for debate: AIDebate) async throws -> DebateTurn {
        try await Task.sleep(nanoseconds: 1_500_000_000)

        let aiTurns = debate.turns.filter { $0.speaker == .ai }

        var closingText = "## Debate Summary\n\n"
        closingText += "**Original Claim:** \(debate.originalClaim)\n\n"
        closingText += "### Key Exchanges\n"

        for turn in aiTurns {
            let preview = String(turn.content.prefix(100))
            closingText += "- \(turn.round.rawValue): \(preview)...\n"
        }

        closingText += "\n### Detected Reasoning Issues\n"
        for fallacy in debate.detectedFallacies {
            closingText += "- \(fallacy.fallacyType.rawValue): \(fallacy.excerpt)\n"
        }

        if debate.detectedFallacies.isEmpty {
            closingText += "- No significant logical fallacies detected in this debate.\n"
        }

        closingText += "\n### Final Assessment\n"
        let strengthScore = calculateDebateStrength(debate)
        closingText += "The debate revealed \(strengthScore.issues) key issues with the original claim. "
        closingText += "Overall argument strength: \(strengthScore.label)."

        return DebateTurn(
            round: .closing,
            speaker: .ai,
            content: closingText,
            isAIGenerated: true
        )
    }

    // MARK: - Debate Evaluation

    func evaluateTurn(_ turn: DebateTurn, against claim: String) async throws -> DebateEvaluation {
        let fallacyService = FallacyDetectionService.shared
        let fallacies = try await fallacyService.detectFallacies(in: turn.content)

        let fallacyPenalty = fallacies.reduce(0.0) { $0 + Double($1.fallacyType.severity) * 0.1 }
        let score = max(0.0, min(1.0, 1.0 - fallacyPenalty))

        let strength: DebateStrength
        if score >= 0.8 {
            strength = .strong
        } else if score >= 0.5 {
            strength = .moderate
        } else {
            strength = .weak
        }

        return DebateEvaluation(
            turnId: turn.id,
            score: score,
            strength: strength,
            detectedFallacies: fallacies,
            feedback: generateEvaluationFeedback(score: score, fallacies: fallacies)
        )
    }

    // MARK: - Private Helpers

    private func generateStandardChallenges(for claim: String) -> [CounterArgument] {
        let wordCount = claim.split(separator: " ").count

        var challenges: [CounterArgument] = []

        if wordCount < 10 {
            challenges.append(CounterArgument(
                type: .factual,
                text: "This claim lacks sufficient detail to evaluate properly. More specifics would help assess its validity.",
                severity: 2,
                confidenceScore: 0.75
            ))
        }

        challenges.append(CounterArgument(
            type: .logical,
            text: "The reasoning structure needs examination. What evidence supports the causal relationship being asserted?",
            severity: 3,
            confidenceScore: 0.80
        ))

        challenges.append(CounterArgument(
            type: .practical,
            text: "Even if this claim is valid in theory, what barriers exist to implementing or acting on it in practice?",
            severity: 2,
            confidenceScore: 0.78
        ))

        let lowercased = claim.lowercased()
        if lowercased.contains("always") || lowercased.contains("never") || lowercased.contains("all") {
            challenges.append(CounterArgument(
                type: .logical,
                text: "Absolute language detected. Claims using 'always', 'never', or 'all' are statistically likely to have exceptions.",
                severity: 3,
                confidenceScore: 0.85
            ))
        }

        challenges.append(CounterArgument(
            type: .emotional,
            text: "Is this argument relying on emotional appeal rather than presenting objective evidence?",
            severity: 1,
            confidenceScore: 0.70
        ))

        return challenges
    }

    private func generateGeneralAssumptionChallenges(for claim: String) -> [Challenge] {
        var challenges: [Challenge] = []

        let lowercased = claim.lowercased()

        if lowercased.contains("because") || lowercased.contains("therefore") {
            challenges.append(Challenge(
                assumption: "X causes Y",
                text: "The causal link implied here assumes correlation equals causation. What evidence establishes directionality?",
                type: .falseCausality,
                strength: 2
            ))
        }

        if lowercased.contains("experts say") || lowercased.contains("studies show") {
            challenges.append(Challenge(
                assumption: "Authority figures or studies support this claim",
                text: "Which experts? Which studies? Appeal to authority requires specifying who and what.",
                type: .appealToAuthority,
                strength: 2
            ))
        }

        if lowercased.contains("if we don't") || lowercased.contains("then next") {
            challenges.append(Challenge(
                assumption: "One event will inevitably lead to a chain of consequences",
                text: "The slippery slope logic here lacks evidence for each step in the chain.",
                type: .slipperySlope,
                strength: 2
            ))
        }

        return challenges
    }

    private func extractAssumption(from claim: String, fallacy: DetectedFallacy) -> String {
        switch fallacy.fallacyType {
        case .strawMan: return "The argument accurately represents all opposing viewpoints"
        case .adHominem: return "The character of the person making the argument affects its truth"
        case .falseDichotomy: return "Only two options are possible"
        case .appealToAuthority: return "Authority figures are always correct in their domain"
        case .slipperySlope: return "One event will inevitably cause a chain of negative events"
        case .circularReasoning: return "The conclusion is true because the premises are true"
        case .hastyGeneralization: return "A limited sample represents the whole"
        case .redHerring: return "The original topic is the relevant one"
        case .appealToEmotion: return "Emotional resonance indicates truth"
        case .falseCausality: return "Correlation between events proves causation"
        }
    }

    private func generateAIOpening(for claim: String) -> String {
        return """
        The claim presented is: "\(claim)"

        I will examine this argument critically across four dimensions:
        1. Factual accuracy — are the underlying facts correct?
        2. Logical structure — does the reasoning hold?
        3. Emotional bias — is emotion being used to compensate for weak evidence?
        4. Practical feasibility — would this work in reality?

        Let us begin.
        """
    }

    private func generateCounterArgumentText(against argument: String) -> String {
        return """
        Beyond the logical issues identified, consider the following:

        1. **Evidence Gap**: What empirical data supports the core claim? Without specific studies, statistics, or documented examples, the argument rests on assertion.

        2. **Alternative Explanations**: Could the observed phenomena be explained by other factors? Occam's razor suggests preferring simpler explanations with fewer assumptions.

        3. **Counterexamples**: History provides numerous cases where similar arguments were made and subsequently disproven. The burden of proof lies with the claimant.

        4. **Burden of Proof**: Remember: extraordinary claims require extraordinary evidence. The more counterintuitive a claim, the stronger the evidence required.
        """
    }

    private func generateCrossExaminationQuestions() -> String {
        let questions = [
            "Can you provide a specific, verifiable example that supports your central claim?",
            "What would convince you that your position is incorrect? Define this in advance.",
            "If your primary evidence were shown to be inaccurate, would your conclusion still hold? Why?",
            "Who benefits from your conclusion being accepted, and does that create any bias?",
            "What assumptions are you making that you cannot prove?",
            "Is your argument based on how things are, or how you believe things should be?",
            "Have you considered how this argument applies to edge cases or exceptions?",
            "What is the simplest explanation for the phenomenon you're describing?"
        ]

        var result = "Cross-Examination Questions:\n\n"
        for (i, q) in questions.enumerated() {
            result += "\(i + 1). \(q)\n"
        }
        result += "\n*Select the question(s) you wish to respond to, or pose your own.*"
        return result
    }

    private func calculateDebateStrength(_ debate: AIDebate) -> (issues: Int, label: String) {
        let issueCount = debate.detectedFallacies.count
        let totalTurns = debate.turns.count

        let label: String
        if issueCount == 0 && totalTurns >= 4 {
            label = "Strong — the argument held up well under sustained scrutiny"
        } else if issueCount <= 2 {
            label = "Moderate — some weaknesses were identified but core claim remains defensible"
        } else {
            label = "Weak — significant logical issues undermine the argument's validity"
        }

        return (issueCount, label)
    }

    private func generateEvaluationFeedback(score: Double, fallacies: [DetectedFallacy]) -> String {
        if fallacies.isEmpty {
            return "Strong reasoning. No logical fallacies detected in this turn."
        }

        var feedback = "This turn contained \(fallacies.count) logical \(fallacies.count == 1 ? "fallacy" : "fallacies"):\n"
        for fallacy in fallacies {
            feedback += "• \(fallacy.fallacyType.rawValue): \(fallacy.explanation)\n"
        }
        feedback += "\nConsider addressing these before proceeding to the next round."
        return feedback
    }
}
