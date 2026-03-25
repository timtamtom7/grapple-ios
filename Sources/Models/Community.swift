import Foundation

struct TopicCategory: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let icon: String
    let color: String
    let sessionCount: Int

    init(id: UUID = UUID(), name: String, icon: String, color: String, sessionCount: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.sessionCount = sessionCount
    }

    static let samples: [TopicCategory] = [
        TopicCategory(name: "Philosophy", icon: "brain", color: "9B59B6", sessionCount: 142),
        TopicCategory(name: "Science", icon: "atom", color: "3498DB", sessionCount: 203),
        TopicCategory(name: "Politics", icon: "building.columns", color: "E74C3C", sessionCount: 89),
        TopicCategory(name: "Technology", icon: "desktopcomputer", color: "27AE60", sessionCount: 317),
        TopicCategory(name: "Ethics", icon: "scale.3d", color: "F39C12", sessionCount: 76),
        TopicCategory(name: "Economics", icon: "chart.line.uptrend.xyaxis", color: "1ABC9C", sessionCount: 65),
        TopicCategory(name: "Culture", icon: "theatermasks", color: "E91E63", sessionCount: 54),
        TopicCategory(name: "Environment", icon: "leaf", color: "2ECC71", sessionCount: 43)
    ]
}

struct CommunityUser: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    let displayName: String
    let avatarColor: String
    var followerCount: Int
    var followingCount: Int
    var isFollowing: Bool
    var sessionCount: Int

    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        avatarColor: String = "4A90D9",
        followerCount: Int = 0,
        followingCount: Int = 0,
        isFollowing: Bool = false,
        sessionCount: Int = 0
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarColor = avatarColor
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.isFollowing = isFollowing
        self.sessionCount = sessionCount
    }

    var initials: String {
        let parts = displayName.components(separatedBy: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        }
        return String(displayName.prefix(2)).uppercased()
    }
}

struct PublicSession: Identifiable, Codable, Equatable {
    let id: UUID
    let user: CommunityUser
    let topic: String
    let debateMode: DebateMode
    let category: String
    let verdict: String
    let outcome: SessionOutcome
    let createdAt: Date
    var likeCount: Int
    var responseCount: Int
    var isBookmarked: Bool
    var isLiked: Bool

    init(
        id: UUID = UUID(),
        user: CommunityUser,
        topic: String,
        debateMode: DebateMode = .standard,
        category: String = "General",
        verdict: String,
        outcome: SessionOutcome = .mixed,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        responseCount: Int = 0,
        isBookmarked: Bool = false,
        isLiked: Bool = false
    ) {
        self.id = id
        self.user = user
        self.topic = topic
        self.debateMode = debateMode
        self.category = category
        self.verdict = verdict
        self.outcome = outcome
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.responseCount = responseCount
        self.isBookmarked = isBookmarked
        self.isLiked = isLiked
    }
}

struct Bookmark: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let createdAt: Date

    init(id: UUID = UUID(), sessionId: UUID, createdAt: Date = Date()) {
        self.id = id
        self.sessionId = sessionId
        self.createdAt = createdAt
    }
}
