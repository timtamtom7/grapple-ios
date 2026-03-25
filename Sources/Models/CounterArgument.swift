import Foundation

struct CounterArgument: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ArgumentType
    let text: String
    let severity: Int
    var confidenceScore: Double
    var sourceAttribution: String?

    init(id: UUID = UUID(), type: ArgumentType, text: String, severity: Int, confidenceScore: Double = 0.7, sourceAttribution: String? = nil) {
        self.id = id
        self.type = type
        self.text = text
        self.severity = max(1, min(3, severity))
        self.confidenceScore = max(0.0, min(1.0, confidenceScore))
        self.sourceAttribution = sourceAttribution
    }

    var confidenceLevel: ConfidenceLevel {
        if confidenceScore >= 0.7 { return .high }
        else if confidenceScore >= 0.4 { return .medium }
        else { return .low }
    }
}
