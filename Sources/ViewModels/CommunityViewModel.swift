import Foundation
import Combine

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published var selectedTab: CommunityTab = .feed
    @Published var isRefreshing = false

    func switchTab(to tab: CommunityTab) {
        selectedTab = tab
    }
}

enum CommunityTab: String, CaseIterable {
    case feed = "Feed"
    case topics = "Topics"
    case bookmarks = "Bookmarks"
}
