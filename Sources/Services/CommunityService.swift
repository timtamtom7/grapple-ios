import Foundation

@MainActor
final class CommunityService: ObservableObject {
    static let shared = CommunityService()

    @Published var publicFeed: [PublicSession] = []
    @Published var bookmarks: [PublicSession] = []
    @Published var isLoadingFeed = false
    @Published var selectedCategory: TopicCategory?

    private init() {
        publicFeed = Self.mockFeed
    }

    // MARK: - Feed

    func loadFeed(for category: TopicCategory? = nil) async {
        isLoadingFeed = true
        defer { isLoadingFeed = false }

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 800_000_000)

        if let category = category {
            publicFeed = Self.mockFeed.filter { $0.category == category.name }
        } else {
            publicFeed = Self.mockFeed
        }
    }

    func refreshFeed() async {
        await loadFeed(for: selectedCategory)
    }

    // MARK: - Interactions

    func toggleLike(session: PublicSession) {
        if let index = publicFeed.firstIndex(where: { $0.id == session.id }) {
            if publicFeed[index].isLiked {
                publicFeed[index].isLiked = false
                publicFeed[index].likeCount -= 1
            } else {
                publicFeed[index].isLiked = true
                publicFeed[index].likeCount += 1
            }
        }
    }

    func toggleBookmark(session: PublicSession) {
        if let index = publicFeed.firstIndex(where: { $0.id == session.id }) {
            publicFeed[index].isBookmarked.toggle()
            let isNowBookmarked = publicFeed[index].isBookmarked

            if isNowBookmarked {
                bookmarks.append(publicFeed[index])
            } else {
                bookmarks.removeAll { $0.id == session.id }
            }
        }
    }

    func followUser(_ user: CommunityUser) {
        // Toggle follow - would update backend in real app
    }

    // MARK: - Categories

    var categories: [TopicCategory] {
        TopicCategory.samples
    }

    func sessionsForCategory(_ category: TopicCategory) async -> [PublicSession] {
        await loadFeed(for: category)
        return publicFeed
    }

    // MARK: - Mock Data

    private static let mockFeed: [PublicSession] = [
        PublicSession(
            user: CommunityUser(username: "philosophy_enjoyer", displayName: "Sarah Chen", avatarColor: "9B59B6", followerCount: 234, sessionCount: 18),
            topic: "Free will is an illusion — neuroscience proves it",
            debateMode: .deepDive,
            category: "Philosophy",
            verdict: "The evidence from neuroscience is compelling but not conclusive. While our brains initiate actions before we're consciously aware, this doesn't necessarily disprove free will — it may simply reveal a different mechanism of agency than classical notions suggest.",
            outcome: .strong,
            createdAt: Date().addingTimeInterval(-3600),
            likeCount: 47,
            responseCount: 12
        ),
        PublicSession(
            user: CommunityUser(username: "logicfirst", displayName: "Marcus Webb", avatarColor: "3498DB", followerCount: 891, sessionCount: 45),
            topic: "AI will surpass human intelligence within 20 years",
            debateMode: .standard,
            category: "Technology",
            verdict: "The trajectory of AI progress suggests this is plausible, but 'surpass' is ambiguous. AI may exceed human performance on specific tasks well before achieving general intelligence, and the timeline estimates vary widely among experts.",
            outcome: .mixed,
            createdAt: Date().addingTimeInterval(-7200),
            likeCount: 89,
            responseCount: 31
        ),
        PublicSession(
            user: CommunityUser(username: "economics_daily", displayName: "Aisha Patel", avatarColor: "1ABC9C", followerCount: 156,
                                sessionCount: 22),
            topic: "Universal basic income is economically viable",
            debateMode: .opposingView,
            category: "Economics",
            verdict: "The economic viability depends heavily on implementation design, funding mechanisms, and offset programs. Pilot programs show mixed results — some improve wellbeing without harming employment, but scaling to national level introduces significant unknowns.",
            outcome: .weak,
            createdAt: Date().addingTimeInterval(-14400),
            likeCount: 63,
            responseCount: 24
        ),
        PublicSession(
            user: CommunityUser(username: "climate_realist", displayName: "James O'Brien", avatarColor: "2ECC71", followerCount: 445, sessionCount: 30),
            topic: "Nuclear power is essential for carbon neutrality",
            debateMode: .standard,
            category: "Environment",
            verdict: "The evidence strongly supports nuclear as a low-carbon baseload power source with proven safety record in modern plants. The main barriers are cost and public perception rather than technical or environmental concerns.",
            outcome: .strong,
            createdAt: Date().addingTimeInterval(-28800),
            likeCount: 112,
            responseCount: 28
        ),
        PublicSession(
            user: CommunityUser(username: "bioethics_now", displayName: "Yuki Tanaka", avatarColor: "E91E63", followerCount: 321, sessionCount: 15),
            topic: "Gene editing embryos is ethically permissible",
            debateMode: .deepDive,
            category: "Ethics",
            verdict: "The ethical permissibility depends on the purpose and safety. Editing to prevent serious genetic diseases may be justified, while enhancement for non-medical traits raises more serious concerns about equity and human dignity.",
            outcome: .mixed,
            createdAt: Date().addingTimeInterval(-43200),
            likeCount: 55,
            responseCount: 19
        ),
        PublicSession(
            user: CommunityUser(username: "science_reader", displayName: "Oliver Hart", avatarColor: "F39C12", followerCount: 178, sessionCount: 11),
            topic: "The multiverse interpretation of quantum mechanics is科学",
            debateMode: .quick,
            category: "Science",
            verdict: "The Many-Worlds Interpretation is mathematically coherent but currently unfalsifiable — making it more philosophical than scientific in the strict sense. It remains a useful interpretational framework rather than empirically confirmed theory.",
            outcome: .weak,
            createdAt: Date().addingTimeInterval(-86400),
            likeCount: 38,
            responseCount: 15
        )
    ]
}
