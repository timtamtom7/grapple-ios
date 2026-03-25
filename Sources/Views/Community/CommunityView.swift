import SwiftUI

struct CommunityView: View {
    @StateObject private var communityService = CommunityService.shared
    @StateObject private var viewModel = CommunityViewModel()
    @State private var selectedTab: CommunityTab = .feed
    @State private var showTopicExplorer = false
    @State private var selectedPublicSession: PublicSession?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab bar
                    tabBar

                    // Content
                    TabView(selection: $selectedTab) {
                        FeedView(communityService: communityService) { session in
                            selectedPublicSession = session
                        }
                        .tag(CommunityTab.feed)

                        TopicExplorerView(communityService: communityService) { session in
                            selectedPublicSession = session
                        }
                        .tag(CommunityTab.topics)

                        BookmarksView(communityService: communityService) { session in
                            selectedPublicSession = session
                        }
                        .tag(CommunityTab.bookmarks)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "0F1419"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedPublicSession) { session in
                PublicSessionDetailView(session: session, communityService: communityService)
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(CommunityTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? Color(hex: "4A90D9") : Color(hex: "8B9BB4"))

                        Rectangle()
                            .fill(selectedTab == tab ? Color(hex: "4A90D9") : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "0F1419"))
    }
}

// MARK: - Feed View

struct FeedView: View {
    @ObservedObject var communityService: CommunityService
    let onSelect: (PublicSession) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(communityService.publicFeed) { session in
                    PublicSessionCard(session: session, communityService: communityService)
                        .onTapGesture {
                            onSelect(session)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            await communityService.refreshFeed()
        }
        .task {
            if communityService.publicFeed.isEmpty {
                await communityService.loadFeed()
            }
        }
        .overlay {
            if communityService.isLoadingFeed && communityService.publicFeed.isEmpty {
                ProgressView()
                    .tint(Color(hex: "4A90D9"))
            }
        }
    }
}

// MARK: - Topic Explorer View

struct TopicExplorerView: View {
    @ObservedObject var communityService: CommunityService
    let onSelect: (PublicSession) -> Void
    @State private var selectedCategory: TopicCategory?
    @State private var categorySessions: [PublicSession] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Category grid
                Text("Browse by Topic")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(communityService.categories) { category in
                        CategoryCard(category: category, isSelected: selectedCategory?.id == category.id)
                            .onTapGesture {
                                if selectedCategory?.id == category.id {
                                    selectedCategory = nil
                                    categorySessions = []
                                } else {
                                    selectedCategory = category
                                    loadCategorySessions(category)
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)

                // Sessions for selected category
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color(hex: "4A90D9"))
                        Spacer()
                    }
                    .padding(.top, 20)
                } else if !categorySessions.isEmpty {
                    Text("Sessions in \(selectedCategory?.name ?? "")")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)

                    ForEach(categorySessions) { session in
                        PublicSessionCard(session: session, communityService: communityService)
                            .onTapGesture { onSelect(session) }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
    }

    private func loadCategorySessions(_ category: TopicCategory) {
        isLoading = true
        Task {
            categorySessions = await communityService.sessionsForCategory(category)
            isLoading = false
        }
    }
}

// MARK: - Bookmarks View

struct BookmarksView: View {
    @ObservedObject var communityService: CommunityService
    let onSelect: (PublicSession) -> Void

    var body: some View {
        Group {
            if communityService.bookmarks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "4A90D9").opacity(0.4))
                    Text("No bookmarks yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "8B9BB4"))
                    Text("Bookmark sessions from the community feed to save them here.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6B7280"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(communityService.bookmarks) { session in
                            PublicSessionCard(session: session, communityService: communityService)
                                .onTapGesture { onSelect(session) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }
}

// MARK: - Public Session Card

struct PublicSessionCard: View {
    let session: PublicSession
    @ObservedObject var communityService: CommunityService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: user + category
            HStack(spacing: 8) {
                // Avatar
                Circle()
                    .fill(Color(hex: session.user.avatarColor))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(session.user.initials)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(session.user.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Text("@\(session.user.username)")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8B9BB4"))
                        Text("·")
                            .foregroundColor(Color(hex: "6B7280"))
                        Text(timeAgo(session.createdAt))
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                }

                Spacer()

                // Category badge
                Text(session.category)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "4A90D9"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color(hex: "4A90D9").opacity(0.12)))
            }

            // Topic
            Text(session.topic)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(3)
                .lineSpacing(3)

            // Verdict preview
            Text(session.verdict)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineLimit(4)
                .lineSpacing(3)

            Divider()
                .background(Color(hex: "2D3F54"))

            // Stats + actions
            HStack(spacing: 16) {
                // Likes
                HStack(spacing: 4) {
                    Button(action: {
                        communityService.toggleLike(session: session)
                    }) {
                        Image(systemName: session.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundColor(session.isLiked ? Color(hex: "E63946") : Color(hex: "8B9BB4"))
                    }
                    Text("\(session.likeCount)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }

                // Responses
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8B9BB4"))
                    Text("\(session.responseCount)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }

                // Bookmark
                Spacer()

                Button(action: {
                    communityService.toggleBookmark(session: session)
                }) {
                    Image(systemName: session.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 13))
                        .foregroundColor(session.isBookmarked ? Color(hex: "F4A261") : Color(hex: "8B9BB4"))
                }

                // Share
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }
            }
        }
        .padding(14)
        .background(Color(hex: "1A2332"))
        .cornerRadius(10)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: TopicCategory
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: category.color).opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: category.color))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(category.sessionCount) sessions")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8B9BB4"))
            }

            Spacer()
        }
        .padding(12)
        .background(Color(hex: isSelected ? "243044" : "1A2332"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color(hex: category.color).opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Public Session Detail View

struct PublicSessionDetailView: View {
    let session: PublicSession
    @ObservedObject var communityService: CommunityService
    @Environment(\.dismiss) private var dismiss
    @State private var rebuttalText: String = ""
    @State private var showRebuttalInput = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // User header
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: session.user.avatarColor))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text(session.user.initials)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(session.user.displayName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("@\(session.user.username)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "8B9BB4"))
                                HStack(spacing: 8) {
                                    Text("\(session.user.followerCount) followers")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "8B9BB4"))
                                    Text("·")
                                        .foregroundColor(Color(hex: "6B7280"))
                                    Text(timeAgo(session.createdAt))
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "8B9BB4"))
                                }
                            }

                            Spacer()

                            Button(action: {
                                communityService.followUser(session.user)
                            }) {
                                Text(session.user.isFollowing ? "Following" : "Follow")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(session.user.isFollowing ? Color(hex: "8B9BB4") : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(session.user.isFollowing ? Color(hex: "2D3F54") : Color(hex: "4A90D9"))
                                    )
                            }
                        }

                        // Topic
                        Text(session.topic)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(4)

                        // Category + Mode
                        HStack(spacing: 8) {
                            Text(session.category)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "4A90D9"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color(hex: "4A90D9").opacity(0.12)))

                            Text(session.debateMode.rawValue)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "52B788"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color(hex: "52B788").opacity(0.12)))
                        }

                        // Verdict
                        VStack(alignment: .leading, spacing: 8) {
                            Text("VERDICT")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "52B788"))

                            Text(session.verdict)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "1A2332"))
                        .cornerRadius(10)

                        // Stats
                        HStack(spacing: 24) {
                            statItem(icon: "heart", count: session.likeCount, label: "likes")
                            statItem(icon: "bubble.left", count: session.responseCount, label: "rebuttals")
                            statItem(icon: "bookmark", count: nil, label: session.isBookmarked ? "saved" : "save")
                        }
                        .padding(.vertical, 8)

                        // Rebuttal CTA
                        Button(action: { showRebuttalInput.toggle() }) {
                            HStack {
                                Image(systemName: "arrowshape.turn.up.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Write a Rebuttal")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "4A90D9")))
                        }

                        if showRebuttalInput {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Rebuttal")
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Color(hex: "8B9BB4"))

                                TextEditor(text: $rebuttalText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 100)
                                    .padding(10)
                                    .background(Color(hex: "1A2332"))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "4A90D9").opacity(0.3), lineWidth: 1)
                                    )

                                Button(action: {
                                    // Submit rebuttal
                                    showRebuttalInput = false
                                    rebuttalText = ""
                                }) {
                                    Text("Submit Rebuttal")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "52B788")))
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "4A90D9"))
                }
            }
        }
    }

    @ViewBuilder
    private func statItem(icon: String, count: Int?, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8B9BB4"))
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "8B9BB4"))
            }
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "8B9BB4"))
        }
    }
}

// MARK: - Helper

func timeAgo(_ date: Date) -> String {
    let interval = Date().timeIntervalSince(date)
    if interval < 60 {
        return "just now"
    } else if interval < 3600 {
        let minutes = Int(interval / 60)
        return "\(minutes)m ago"
    } else if interval < 86400 {
        let hours = Int(interval / 3600)
        return "\(hours)h ago"
    } else {
        let days = Int(interval / 86400)
        return "\(days)d ago"
    }
}
