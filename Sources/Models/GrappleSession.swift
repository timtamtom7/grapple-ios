import Foundation

struct GrappleSession: Identifiable, Codable {
    let id: UUID
    var topic: String
    var originalInput: String
    var counterArguments: [CounterArgument]
    var rebuttals: [Rebuttal]
    var synthesis: Synthesis?
    var outcome: SessionOutcome
    let createdAt: Date

    init(
        id: UUID = UUID(),
        topic: String,
        originalInput: String,
        counterArguments: [CounterArgument] = [],
        rebuttals: [Rebuttal] = [],
        synthesis: Synthesis? = nil,
        outcome: SessionOutcome = .mixed,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.topic = topic
        self.originalInput = originalInput
        self.counterArguments = counterArguments
        self.rebuttals = rebuttals
        self.synthesis = synthesis
        self.outcome = outcome
        self.createdAt = createdAt
    }
}
