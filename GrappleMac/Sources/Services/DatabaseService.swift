import Foundation

@MainActor
final class DatabaseService: ObservableObject {
    static let shared = DatabaseService()

    private let userDefaultsKey = "GrappleMac.sessions"
    @Published var sessionsList: [GrappleSession] = []

    private init() {
        loadSessions()
    }

    func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            sessionsList = []
            return
        }
        do {
            sessionsList = try JSONDecoder().decode([GrappleSession].self, from: data)
        } catch {
            sessionsList = []
        }
    }

    func saveSession(_ session: GrappleSession) {
        var sessions = sessionsList.filter { $0.id != session.id }
        sessions.insert(session, at: 0)
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            sessionsList = sessions
        } catch {
            print("Save session error: \(error)")
        }
    }

    func deleteSession(_ session: GrappleSession) {
        var sessions = sessionsList.filter { $0.id != session.id }
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            sessionsList = sessions
        } catch {
            print("Delete session error: \(error)")
        }
    }
}
