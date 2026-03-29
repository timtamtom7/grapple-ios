import Foundation
import Combine

@MainActor
class MacHistoryViewModel: ObservableObject {
    @Published var sessions: [GrappleSession] = []

    private let databaseService = DatabaseService.shared

    init() {
        load()
    }

    func load() {
        databaseService.loadSessions()
        sessions = databaseService.sessionsList
        sessions.sort { $0.createdAt > $1.createdAt }
    }

    func delete(_ session: GrappleSession) {
        databaseService.deleteSession(session)
        load()
    }

    func refresh() {
        load()
    }
}
