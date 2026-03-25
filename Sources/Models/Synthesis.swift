import Foundation

struct Synthesis: Codable {
    var whatSurvived: String
    var whatCollapsed: String
    var needsEvidence: String
    var verdict: String

    init(whatSurvived: String = "", whatCollapsed: String = "", needsEvidence: String = "", verdict: String = "") {
        self.whatSurvived = whatSurvived
        self.whatCollapsed = whatCollapsed
        self.needsEvidence = needsEvidence
        self.verdict = verdict
    }
}
