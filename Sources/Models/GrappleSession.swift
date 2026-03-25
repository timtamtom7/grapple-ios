import Foundation
import SwiftUI

struct GrappleSession: Identifiable, Codable {
    let id: UUID
    var topic: String
    var originalInput: String
    var counterArguments: [CounterArgument]
    var rebuttals: [Rebuttal]
    var synthesis: Synthesis?
    var outcome: SessionOutcome
    var debateMode: DebateMode
    var sourceURLs: [String]
    var factChecks: [FactCheckItem]
    let createdAt: Date
    var isPublic: Bool
    var category: String

    init(
        id: UUID = UUID(),
        topic: String,
        originalInput: String,
        counterArguments: [CounterArgument] = [],
        rebuttals: [Rebuttal] = [],
        synthesis: Synthesis? = nil,
        outcome: SessionOutcome = .mixed,
        debateMode: DebateMode = .standard,
        sourceURLs: [String] = [],
        factChecks: [FactCheckItem] = [],
        createdAt: Date = Date(),
        isPublic: Bool = false,
        category: String = "General"
    ) {
        self.id = id
        self.topic = topic
        self.originalInput = originalInput
        self.counterArguments = counterArguments
        self.rebuttals = rebuttals
        self.synthesis = synthesis
        self.outcome = outcome
        self.debateMode = debateMode
        self.sourceURLs = sourceURLs
        self.factChecks = factChecks
        self.createdAt = createdAt
        self.isPublic = isPublic
        self.category = category
    }
}
