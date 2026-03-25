import Foundation

struct CounterArgument: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ArgumentType
    let text: String
    let severity: Int

    init(id: UUID = UUID(), type: ArgumentType, text: String, severity: Int) {
        self.id = id
        self.type = type
        self.text = text
        self.severity = max(1, min(3, severity))
    }
}
