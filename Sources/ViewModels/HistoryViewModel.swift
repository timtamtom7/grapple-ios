import Foundation

struct TopicStat: Identifiable {
    let id = UUID()
    let topic: String
    let count: Int
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var sessions: [GrappleSession] = []
    @Published var selectedSession: GrappleSession?

    private let databaseService = DatabaseService.shared

    var topTopics: [TopicStat] {
        var topicCounts: [String: Int] = [:]
        for session in sessions {
            let key = session.topic.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            topicCounts[key, default: 0] += 1
        }
        return topicCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { TopicStat(topic: $0.key.capitalized, count: $0.value) }
    }

    var groupedSessions: [String: [GrappleSession]] {
        Dictionary(grouping: sessions) { session in
            let components = session.topic.components(separatedBy: " ")
            return components.prefix(3).joined(separator: " ")
        }
    }

    func filteredSessions(_ query: String) -> [GrappleSession] {
        if query.isEmpty {
            return sessions
        }
        let lower = query.lowercased()
        return sessions.filter {
            $0.topic.lowercased().contains(lower) ||
            $0.originalInput.lowercased().contains(lower) ||
            $0.debateMode.rawValue.lowercased().contains(lower)
        }
    }

    func groupedFiltered(_ query: String) -> [(key: String, value: [GrappleSession])] {
        let filtered = filteredSessions(query)
        var grouped = Dictionary(grouping: filtered) { session in
            let components = session.topic.components(separatedBy: " ")
            return components.prefix(3).joined(separator: " ")
        }
        return grouped.sorted { $0.value.count > $1.value.count }
    }

    func load() {
        sessions = databaseService.sessionsList
    }

    func delete(_ session: GrappleSession) {
        databaseService.deleteSession(session)
        load()
    }
}
