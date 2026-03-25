import Foundation

struct Rebuttal: Identifiable, Codable {
    let id: UUID
    let argumentId: UUID
    var text: String
    var judgment: RebuttalJudgment
    var confidenceLevel: ConfidenceLevel

    init(id: UUID = UUID(), argumentId: UUID, text: String = "", judgment: RebuttalJudgment = .weak, confidenceLevel: ConfidenceLevel = .medium) {
        self.id = id
        self.argumentId = argumentId
        self.text = text
        self.judgment = judgment
        self.confidenceLevel = confidenceLevel
    }
}
