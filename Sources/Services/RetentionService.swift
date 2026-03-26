import Foundation
import SwiftUI

/// R13: Retention tracking for Grapple
/// Day 1: first debate
/// Day 3: first synthesis
/// Day 7: first tournament
@MainActor
final class RetentionService: ObservableObject {
    static let shared = RetentionService()

    private let installDateKey = "grapple_install_date"
    private let day1DebateKey = "day1_debate_completed"
    private let day3SynthesisKey = "day3_synthesis_completed"
    private let day7TournamentKey = "day7_tournament_completed"
    private let lastActiveKey = "grapple_last_active"

    @Published var daysSinceInstall: Int = 0
    @Published var day1Completed: Bool = false
    @Published var day3Completed: Bool = false
    @Published var day7Completed: Bool = false

    var currentMilestone: RetentionMilestone {
        if day7Completed { return .completed }
        else if day3Completed { return .day7 }
        else if day1Completed { return .day3 }
        else { return .day1 }
    }

    enum RetentionMilestone: String {
        case day1 = "Join your first debate"
        case day3 = "Get your first AI synthesis"
        case day7 = "Enter your first tournament"
        case completed = "Grapple active!"
    }

    init() {
        loadRetentionData()
    }

    func loadRetentionData() {
        if let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date {
            daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        } else {
            UserDefaults.standard.set(Date(), forKey: installDateKey)
            daysSinceInstall = 0
        }

        day1Completed = UserDefaults.standard.bool(forKey: day1DebateKey)
        day3Completed = UserDefaults.standard.bool(forKey: day3SynthesisKey)
        day7Completed = UserDefaults.standard.bool(forKey: day7TournamentKey)
        UserDefaults.standard.set(Date(), forKey: lastActiveKey)
    }

    func recordDebateJoined() {
        guard !day1Completed else { return }
        day1Completed = true
        UserDefaults.standard.set(true, forKey: day1DebateKey)
        trackMilestone(.day1)
    }

    func recordSynthesisViewed() {
        guard !day3Completed else { return }
        day3Completed = true
        UserDefaults.standard.set(true, forKey: day3SynthesisKey)
        trackMilestone(.day3)
    }

    func recordTournamentEntered() {
        guard !day7Completed else { return }
        day7Completed = true
        UserDefaults.standard.set(true, forKey: day7TournamentKey)
        trackMilestone(.day7)
    }

    private func trackMilestone(_ milestone: RetentionMilestone) {
        print("[Retention] Milestone completed: \(milestone.rawValue)")
    }
}
