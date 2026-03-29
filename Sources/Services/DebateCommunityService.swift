import Foundation

/// Service for public debate community features: posting debates,
/// browsing the community feed, and upvoting.
@MainActor
final class DebateCommunityService: ObservableObject {
    static let shared = DebateCommunityService()

    @Published var publicDebates: [PublicDebate] = []
    @Published var isLoading = false

    private let debatesKey = "GrappleMac.publicDebates"

    private init() {
        loadMockDebates()
    }

    // MARK: - Public API

    /// Posts a new debate to the community feed.
    /// Returns the assigned postId (UUID string).
    func postDebate(_ debate: Debate) async throws -> String {
        isLoading = true
        defer { isLoading = false }

        // Simulate network latency
        try await Task.sleep(nanoseconds: 600_000_000)

        let publicDebate = PublicDebate(
            id: UUID(),
            topic: debate.topic,
            author: generateAnonymousAuthor(),
            upvotes: 0,
            participantCount: 1,
            createdAt: Date()
        )

        publicDebates.insert(publicDebate, at: 0)
        return publicDebate.id.uuidString
    }

    /// Fetches the list of public debates.
    func getPublicDebates() async throws -> [PublicDebate] {
        isLoading = true
        defer { isLoading = false }

        try await Task.sleep(nanoseconds: 500_000_000)
        return publicDebates
    }

    /// Upvotes a debate post.
    func upvote(postId: UUID) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)

        if let index = publicDebates.firstIndex(where: { $0.id == postId }) {
            let current = publicDebates[index]
            publicDebates[index] = PublicDebate(
                id: current.id,
                topic: current.topic,
                author: current.author,
                upvotes: current.upvotes + 1,
                participantCount: current.participantCount,
                createdAt: current.createdAt
            )
        }
    }

    // MARK: - Mock Data

    private func loadMockDebates() {
        publicDebates = [
            PublicDebate(
                id: UUID(),
                topic: "Is AI consciousness meaningful?",
                author: "anonymous_7f3k",
                upvotes: 142,
                participantCount: 38,
                createdAt: Date().addingTimeInterval(-86400)
            ),
            PublicDebate(
                id: UUID(),
                topic: "Free will is an illusion — neuroscience proves it",
                author: "anonymous_2x9p",
                upvotes: 98,
                participantCount: 27,
                createdAt: Date().addingTimeInterval(-172800)
            ),
            PublicDebate(
                id: UUID(),
                topic: "Universal basic income is economically viable",
                author: "anonymous_5m1q",
                upvotes: 76,
                participantCount: 19,
                createdAt: Date().addingTimeInterval(-259200)
            ),
            PublicDebate(
                id: UUID(),
                topic: "Nuclear power is essential for carbon neutrality",
                author: "anonymous_8r2t",
                upvotes: 203,
                participantCount: 54,
                createdAt: Date().addingTimeInterval(-345600)
            ),
            PublicDebate(
                id: UUID(),
                topic: "Gene editing embryos is ethically permissible",
                author: "anonymous_3j8v",
                upvotes: 61,
                participantCount: 15,
                createdAt: Date().addingTimeInterval(-432000)
            ),
            PublicDebate(
                id: UUID(),
                topic: "The multiverse interpretation is scientifically meaningful",
                author: "anonymous_9w5y",
                upvotes: 44,
                participantCount: 11,
                createdAt: Date().addingTimeInterval(-518400)
            )
        ]
    }

    private func generateAnonymousAuthor() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        let suffix = String((0..<4).map { _ in chars.randomElement()! })
        return "anonymous_\(suffix)"
    }
}

// MARK: - Public Debate Model

struct PublicDebate: Identifiable, Equatable {
    let id: UUID
    let topic: String
    let author: String
    var upvotes: Int
    var participantCount: Int
    let createdAt: Date

    var timeAgo: String {
        let seconds = Int(-createdAt.timeIntervalSinceNow)
        if seconds < 3600 {
            return "\(seconds / 60)m ago"
        } else if seconds < 86400 {
            return "\(seconds / 3600)h ago"
        } else {
            return "\(seconds / 86400)d ago"
        }
    }
}

// MARK: - Debate Model (input type)

struct Debate {
    let topic: String
    let authorId: UUID

    init(topic: String, authorId: UUID = UUID()) {
        self.topic = topic
        self.authorId = authorId
    }
}
