import Foundation

enum ArgumentType: String, Codable, CaseIterable {
    case factual = "Factual"
    case logical = "Logical"
    case emotional = "Emotional"
    case practical = "Practical"

    var icon: String {
        switch self {
        case .factual: return "📊"
        case .logical: return "🔗"
        case .emotional: return "💭"
        case .practical: return "⚙️"
        }
    }

    var description: String {
        switch self {
        case .factual: return "Challenges accuracy of claims"
        case .logical: return "Challenges reasoning structure"
        case .emotional: return "Challenges emotional assumptions"
        case .practical: return "Challenges feasibility"
        }
    }
}

enum RebuttalJudgment: String, Codable {
    case strong = "Strong"
    case partial = "Partial"
    case weak = "Weak"

    var icon: String {
        switch self {
        case .strong: return "✅"
        case .partial: return "⚠️"
        case .weak: return "❌"
        }
    }
}

enum SessionOutcome: String, Codable {
    case strong = "Strong"
    case mixed = "Mixed"
    case weak = "Weak"
}
