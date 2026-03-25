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

enum DebateMode: String, Codable, CaseIterable {
    case quick = "Quick"
    case standard = "Standard"
    case deepDive = "Deep Dive"
    case opposingView = "Opposing View"

    var icon: String {
        switch self {
        case .quick: return "bolt.fill"
        case .standard: return "equal.circle.fill"
        case .deepDive: return "magnifyingglass.circle.fill"
        case .opposingView: return "arrow.left.arrow.right.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .quick: return "3 quick challenges, no rebuttal"
        case .standard: return "Full debate with rebuttals"
        case .deepDive: return "Multiple rounds, AI follow-ups"
        case .opposingView: return "AI argues the opposing side"
        }
    }

    var argumentCount: Int {
        switch self {
        case .quick: return 3
        case .standard: return 5
        case .deepDive: return 8
        case .opposingView: return 5
        }
    }

    var hasRebuttal: Bool {
        switch self {
        case .quick: return false
        case .standard, .deepDive, .opposingView: return true
        }
    }
}

enum ConfidenceLevel: String, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var color: String {
        switch self {
        case .high: return "52B788"
        case .medium: return "F4A261"
        case .low: return "E63946"
        }
    }
}

struct FactCheckItem: Codable, Identifiable {
    let id: UUID
    let claim: String
    let actualData: String
    let confidence: ConfidenceLevel

    init(id: UUID = UUID(), claim: String, actualData: String, confidence: ConfidenceLevel) {
        self.id = id
        self.claim = claim
        self.actualData = actualData
        self.confidence = confidence
    }
}
