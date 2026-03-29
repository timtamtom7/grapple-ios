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
                Theme.Colors.background.ignoresSafeArea()

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
                    #if !os(macOS)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    #endif
                }
            }
            .navigationTitle("Community")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .sheet(item: $selectedPublicSession) { session in
                PublicSessionDetailView(session: session, communityService: communityService)
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(CommunityTab.allCases, id: \.self) { tab in
                Button(action: {
                    Haptics.tabSwitch()
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.system(size: Theme.Typography.bodySmall, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? Theme.Colors.primary : Theme.Colors.textSecondary)

                        Rectangle()
                            .fill(selectedTab == tab ? Theme.Colors.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Community tab: \(tab.rawValue)")
                .accessibilityHint(selectedTab == tab ? "Currently selected" : "Double-tap to select")
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .background(Theme.Colors.background)
    }
}

// MARK: - Feed View

struct FeedView: View {
    @ObservedObject var communityService: CommunityService
    let onSelect: (PublicSession) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(communityService.publicFeed) { session in
                    PublicSessionCard(session: session, communityService: communityService)
                        .onTapGesture {
                            Haptics.cardTap()
                            onSelect(session)
                        }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
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
                    .tint(Theme.Colors.primary)
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
                    .font(Theme.Typography.displayBold(Theme.Typography.sectionTitle))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.horizontal, Theme.Spacing.lg)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                    ForEach(communityService.categories) { category in
                        CategoryCard(category: category, isSelected: selectedCategory?.id == category.id)
                            .onTapGesture {
                                Haptics.cardTap()
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
                .padding(.horizontal, Theme.Spacing.lg)

                // Sessions for selected category
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Theme.Colors.primary)
                        Spacer()
                    }
                    .padding(.top, 20)
                } else if !categorySessions.isEmpty {
                    Text("Sessions in \(selectedCategory?.name ?? "")")
                        .font(Theme.Typography.textSemibold(Theme.Typography.body))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.horizontal, Theme.Spacing.lg)

                    ForEach(categorySessions) { session in
                        PublicSessionCard(session: session, communityService: communityService)
                            .onTapGesture {
                                Haptics.cardTap()
                                onSelect(session)
                            }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }
            }
            .padding(.vertical, Theme.Spacing.lg)
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
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.primary.opacity(0.4))
                    Text("No bookmarks yet")
                        .font(Theme.Typography.textMedium(Theme.Typography.bodyLarge))
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("Bookmark sessions from the community feed to save them here.")
                        .font(Theme.Typography.text(Theme.Typography.bodySmall))
                        .foregroundColor(Theme.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(communityService.bookmarks) { session in
                            PublicSessionCard(session: session, communityService: communityService)
                                .onTapGesture {
                                    Haptics.cardTap()
                                    onSelect(session)
                                }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.md)
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
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header: user + category
            HStack(spacing: Theme.Spacing.sm) {
                // Avatar
                Circle()
                    .fill(Color(hex: session.user.avatarColor))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(session.user.initials)
                            .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(session.user.displayName)
                        .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                        .foregroundColor(Theme.Colors.textPrimary)
                    HStack(spacing: 4) {
                        Text("@\(session.user.username)")
                            .font(Theme.Typography.text(Theme.Typography.caption))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("·")
                            .foregroundColor(Theme.Colors.textTertiary)
                        Text(timeAgo(session.createdAt))
                            .font(Theme.Typography.text(Theme.Typography.caption))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                }

                Spacer()

                // Category badge
                Text(session.category)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.Colors.primary.opacity(0.12)))
            }

            // Topic
            Text(session.topic)
                .font(Theme.Typography.textMedium(Theme.Typography.body))
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(3)
                .lineSpacing(3)

            // Verdict preview
            Text(session.verdict)
                .font(Theme.Typography.text(Theme.Typography.bodySmall))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(4)
                .lineSpacing(3)

            Divider()
                .background(Theme.Colors.divider)

            // Stats + actions
            HStack(spacing: Theme.Spacing.lg) {
                // Likes
                HStack(spacing: 4) {
                    Button(action: {
                        Haptics.lightImpact()
                        communityService.toggleLike(session: session)
                    }) {
                        Image(systemName: session.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: Theme.Typography.caption2))
                            .foregroundColor(session.isLiked ? Theme.Colors.danger : Theme.Colors.textSecondary)
                    }
                    .accessibilityLabel(session.isLiked ? "Unlike" : "Like")
                    Text("\(session.likeCount)")
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Responses
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("\(session.responseCount)")
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                // Bookmark
                Spacer()

                Button(action: {
                    Haptics.toggle()
                    communityService.toggleBookmark(session: session)
                }) {
                    Image(systemName: session.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: Theme.Typography.caption2))
                        .foregroundColor(session.isBookmarked ? Theme.Colors.warning : Theme.Colors.textSecondary)
                }
                .accessibilityLabel(session.isBookmarked ? "Remove bookmark" : "Bookmark session")

                // Share
                Button(action: {
                    Haptics.lightImpact()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .accessibilityLabel("Share session")
            }
        }
        .padding(14)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session about \(session.topic) by \(session.user.displayName)")
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
                        .font(.system(size: Theme.Typography.caption2))
                        .foregroundColor(Color(hex: category.color))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text("\(category.sessionCount) sessions")
                    .font(Theme.Typography.text(Theme.Typography.caption))
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(isSelected ? Theme.Colors.surfaceElevated : Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(isSelected ? Color(hex: category.color).opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .accessibilityLabel("Category: \(category.name), \(category.sessionCount) sessions")
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
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // User header
                        HStack(spacing: Theme.Spacing.md) {
                            Circle()
                                .fill(Color(hex: session.user.avatarColor))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text(session.user.initials)
                                        .font(Theme.Typography.displayBold(16))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(session.user.displayName)
                                    .font(Theme.Typography.textSemibold(Theme.Typography.bodyLarge))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("@\(session.user.username)")
                                    .font(Theme.Typography.text(Theme.Typography.bodySmall))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                HStack(spacing: 8) {
                                    Text("\(session.user.followerCount) followers")
                                        .font(Theme.Typography.text(Theme.Typography.caption2))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                    Text("·")
                                        .foregroundColor(Theme.Colors.textTertiary)
                                    Text(timeAgo(session.createdAt))
                                        .font(Theme.Typography.text(Theme.Typography.caption2))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                            }

                            Spacer()

                            Button(action: {
                                Haptics.buttonTap()
                                communityService.followUser(session.user)
                            }) {
                                Text(session.user.isFollowing ? "Following" : "Follow")
                                    .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                                    .foregroundColor(session.user.isFollowing ? Theme.Colors.textSecondary : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(session.user.isFollowing ? Theme.Colors.divider : Theme.Colors.primary)
                                    )
                            }
                            .accessibilityLabel(session.user.isFollowing ? "Unfollow \(session.user.displayName)" : "Follow \(session.user.displayName)")
                        }

                        // Topic
                        Text(session.topic)
                            .font(Theme.Typography.displayBold(20))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(4)

                        // Category + Mode
                        HStack(spacing: Theme.Spacing.sm) {
                            Text(session.category)
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Theme.Colors.primary.opacity(0.12)))

                            Text(session.debateMode.rawValue)
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Theme.Colors.success.opacity(0.12)))
                        }

                        // Verdict
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("VERDICT")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.success)

                            Text(session.verdict)
                                .font(Theme.Typography.text(Theme.Typography.body))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .lineSpacing(4)
                        }
                        .padding(Theme.Spacing.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.lg)

                        // Stats
                        HStack(spacing: 24) {
                            statItem(icon: "heart", count: session.likeCount, label: "likes")
                            statItem(icon: "bubble.left", count: session.responseCount, label: "rebuttals")
                            statItem(icon: "bookmark", count: nil, label: session.isBookmarked ? "saved" : "save")
                        }
                        .padding(.vertical, Theme.Spacing.sm)

                        // Rebuttal CTA
                        Button(action: {
                            Haptics.buttonTap()
                            showRebuttalInput.toggle()
                        }) {
                            HStack {
                                Image(systemName: "arrowshape.turn.up.left")
                                    .font(.system(size: Theme.Typography.body, weight: .semibold))
                                Text("Write a Rebuttal")
                                    .font(Theme.Typography.textSemibold(Theme.Typography.body))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.lg - 2)
                            .background(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg).fill(Theme.Colors.primary))
                        }
                        .accessibilityLabel("Write a rebuttal")
                        .accessibilityHint("Double-tap to write your own rebuttal to this session")

                        if showRebuttalInput {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Your Rebuttal")
                                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption2))
                                    .foregroundColor(Theme.Colors.textSecondary)

                                TextEditor(text: $rebuttalText)
                                    .font(Theme.Typography.text(Theme.Typography.body))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 100)
                                    .padding(10)
                                    .background(Theme.Colors.surface)
                                    .cornerRadius(Theme.CornerRadius.md)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                            .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                                    )

                                Button(action: {
                                    Haptics.submit()
                                    // Submit rebuttal
                                    showRebuttalInput = false
                                    rebuttalText = ""
                                }) {
                                    Text("Submit Rebuttal")
                                        .font(Theme.Typography.textSemibold(Theme.Typography.body))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(RoundedRectangle(cornerRadius: Theme.CornerRadius.md).fill(Theme.Colors.success))
                                }
                                .accessibilityLabel("Submit your rebuttal")
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Session")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
                #endif
            }
        }
    }

    @ViewBuilder
    private func statItem(icon: String, count: Int?, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: Theme.Typography.bodySmall))
                .foregroundColor(Theme.Colors.textSecondary)
            if let count = count {
                Text("\(count)")
                    .font(Theme.Typography.textMedium(Theme.Typography.bodySmall))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Text(label)
                .font(Theme.Typography.text(Theme.Typography.bodySmall))
                .foregroundColor(Theme.Colors.textSecondary)
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
