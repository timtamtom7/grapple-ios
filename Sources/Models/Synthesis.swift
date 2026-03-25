import Foundation

struct Synthesis: Codable {
    var whatSurvived: String
    var whatCollapsed: String
    var needsEvidence: String
    var verdict: String
    var factChecks: [FactCheckItem]
    var overallConfidence: ConfidenceLevel

    init(whatSurvived: String = "", whatCollapsed: String = "", needsEvidence: String = "", verdict: String = "", factChecks: [FactCheckItem] = [], overallConfidence: ConfidenceLevel = .medium) {
        self.whatSurvived = whatSurvived
        self.whatCollapsed = whatCollapsed
        self.needsEvidence = needsEvidence
        self.verdict = verdict
        self.factChecks = factChecks
        self.overallConfidence = overallConfidence
    }
}
