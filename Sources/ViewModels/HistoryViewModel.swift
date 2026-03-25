import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var sessions: [GrappleSession] = []
    @Published var selectedSession: GrappleSession?

    private let databaseService = DatabaseService.shared

    var groupedSessions: [String: [GrappleSession]] {
        Dictionary(grouping: sessions) { session in
            let components = session.topic.components(separatedBy: " ")
            return components.prefix(3).joined(separator: " ")
        }
    }

    func load() {
        sessions = databaseService.sessionsList
    }

    func delete(_ session: GrappleSession) {
        databaseService.deleteSession(session)
        load()
    }
}
