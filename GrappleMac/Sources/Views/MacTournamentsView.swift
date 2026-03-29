import SwiftUI

/// Displays active debate tournaments and the tournament bracket.
struct MacTournamentsView: View {
    @StateObject private var viewModel = TournamentsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MacTheme.sectionSpacing) {
                headerSection

                if viewModel.isLoading {
                    loadingSection
                } else {
                    activeTournamentsSection
                    bracketSection
                    pastWinnersSection
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(MacTheme.background)
        .task {
            await viewModel.loadTournaments()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tournaments")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(MacTheme.primaryText)

            Text("Compete in structured debate tournaments. Win badges, climb the leaderboard.")
                .font(.system(size: 15))
                .foregroundColor(MacTheme.secondaryText)
        }
    }

    // MARK: - Active Tournaments

    private var activeTournamentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Active Tournaments")

            ForEach(viewModel.activeTournaments) { tournament in
                ActiveTournamentCard(tournament: tournament)
            }
        }
    }

    // MARK: - Bracket

    private var bracketSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionLabel("Tournament Bracket — Logic Open 2026")
                Spacer()
                Text("Round of 8")
                    .font(.system(size: 13))
                    .foregroundColor(MacTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(MacTheme.elevated)
                    .cornerRadius(6)
            }

            TournamentBracketView()
                .frame(height: 320)
        }
    }

    // MARK: - Past Winners

    private var pastWinnersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Hall of Champions")

            ForEach(viewModel.pastWinners) { winner in
                ChampionRow(winner: winner)
            }
        }
    }

    // MARK: - Loading

    private var loadingSection: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(MacTheme.rebuttal)
            Text("Loading tournaments...")
                .font(.system(size: 14))
                .foregroundColor(MacTheme.secondaryText)
                .padding(.top, 12)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(MacTheme.primaryText)
    }
}

// MARK: - Active Tournament Card

struct ActiveTournamentCard: View {
    let tournament: Tournament

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(tournament.color.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: tournament.icon)
                    .font(.system(size: 20))
                    .foregroundColor(tournament.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tournament.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)

                Text("\(tournament.participantCount) participants")
                    .font(.system(size: 13))
                    .foregroundColor(MacTheme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(tournament.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(tournament.statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tournament.statusColor.opacity(0.15))
                    .cornerRadius(4)

                Text("\(tournament.daysLeft)d left")
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.secondaryText)
            }

            Button(action: {}) {
                Text("Enter")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(MacTheme.rebuttal)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }
}

// MARK: - Tournament Bracket View

struct TournamentBracketView: View {
    private let rounds = ["Quarterfinals", "Semifinals", "Finals"]

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(rounds.enumerated()), id: \.offset) { roundIndex, roundName in
                VStack(spacing: 8) {
                    Text(roundName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(MacTheme.secondaryText)

                    if roundIndex == 0 {
                        quarterfinalMatches
                    } else if roundIndex == 1 {
                        semifinalMatches
                    } else {
                        finalMatch
                    }
                }

                if roundIndex < rounds.count - 1 {
                    Spacer()
                    bracketConnector
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }

    private var quarterfinalMatches: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { _ in
                BracketMatchRow(
                    player1: "Player A",
                    player2: "Player B",
                    score1: Int.random(in: 0...3),
                    score2: Int.random(in: 0...3),
                    isDecided: Bool.random()
                )
            }
        }
    }

    private var semifinalMatches: some View {
        VStack(spacing: 24) {
            ForEach(0..<2, id: \.self) { _ in
                BracketMatchRow(
                    player1: "Winner Q1",
                    player2: "Winner Q2",
                    score1: Int.random(in: 0...3),
                    score2: Int.random(in: 0...3),
                    isDecided: Bool.random()
                )
            }
        }
    }

    private var finalMatch: some View {
        VStack(spacing: 8) {
            BracketMatchRow(
                player1: "Winner S1",
                player2: "Winner S2",
                score1: 3,
                score2: 1,
                isDecided: true,
                isHighlighted: true
            )
        }
    }

    private var bracketConnector: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(MacTheme.divider)
                .frame(width: 1)
                .frame(height: 40)
            Spacer()
            Rectangle()
                .fill(MacTheme.divider)
                .frame(width: 1)
                .frame(height: 40)
        }
        .frame(height: 160)
    }
}

// MARK: - Bracket Match Row

struct BracketMatchRow: View {
    let player1: String
    let player2: String
    let score1: Int
    let score2: Int
    let isDecided: Bool
    var isHighlighted: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            playerCell(name: player1, score: score1, isWinner: score1 > score2 && isDecided)
            Rectangle()
                .fill(MacTheme.divider)
                .frame(width: 1, height: 32)
            playerCell(name: player2, score: score2, isWinner: score2 > score1 && isDecided)
        }
        .frame(width: 160, height: 32)
        .background(isHighlighted ? MacTheme.elevated : MacTheme.surface)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isHighlighted ? MacTheme.rebuttal.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }

    private func playerCell(name: String, score: Int, isWinner: Bool) -> some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 11, weight: isWinner ? .semibold : .regular))
                .foregroundColor(isWinner ? MacTheme.primaryText : MacTheme.secondaryText)
                .lineLimit(1)

            Spacer()

            Text("\(score)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isWinner ? MacTheme.success : MacTheme.secondaryText)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Champion Row

struct ChampionRow: View {
    let winner: TournamentWinner

    var body: some View {
        HStack(spacing: 16) {
            // Medal
            ZStack {
                Circle()
                    .fill(medalColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Text(winner.medal)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(winner.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)

                Text(winner.tournamentName)
                    .font(.system(size: 13))
                    .foregroundColor(MacTheme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Logic Champion")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(MacTheme.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(MacTheme.success.opacity(0.15))
                    .cornerRadius(4)

                Text("\(winner.year)")
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.secondaryText)
            }
        }
        .padding(14)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
    }

    private var medalColor: Color {
        switch winner.medal {
        case "🥇": return Color.yellow
        case "🥈": return Color.gray
        case "🥉": return Color.orange
        default: return MacTheme.rebuttal
        }
    }
}

// MARK: - ViewModel

@MainActor
final class TournamentsViewModel: ObservableObject {
    @Published var activeTournaments: [Tournament] = []
    @Published var pastWinners: [TournamentWinner] = []
    @Published var isLoading = false

    func loadTournaments() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 600_000_000)

        activeTournaments = Tournament.samples
        pastWinners = TournamentWinner.samples
    }
}

// MARK: - Models

struct Tournament: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let participantCount: Int
    let status: String
    let statusColor: Color
    let daysLeft: Int

    static let samples: [Tournament] = [
        Tournament(
            name: "Logic Open 2026",
            icon: "brain",
            color: MacTheme.rebuttal,
            participantCount: 128,
            status: "In Progress",
            statusColor: MacTheme.success,
            daysLeft: 14
        ),
        Tournament(
            name: "Philosophy Championship",
            icon: "book",
            color: Color.purple,
            participantCount: 64,
            status: "Registration Open",
            statusColor: MacTheme.rebuttal,
            daysLeft: 21
        ),
        Tournament(
            name: "Ethics Bowl Spring",
            icon: "scale.3d",
            color: Color.orange,
            participantCount: 32,
            status: "Upcoming",
            statusColor: MacTheme.secondaryText,
            daysLeft: 30
        )
    ]
}

struct TournamentWinner: Identifiable {
    let id = UUID()
    let medal: String
    let displayName: String
    let tournamentName: String
    let year: Int

    static let samples: [TournamentWinner] = [
        TournamentWinner(medal: "🥇", displayName: "Sarah Chen", tournamentName: "Logic Open 2025", year: 2025),
        TournamentWinner(medal: "🥇", displayName: "Marcus Webb", tournamentName: "Philosophy Championship 2025", year: 2025),
        TournamentWinner(medal: "🥇", displayName: "Aisha Patel", tournamentName: "Ethics Bowl 2024", year: 2024),
        TournamentWinner(medal: "🥇", displayName: "James O'Brien", tournamentName: "Logic Open 2024", year: 2024)
    ]
}

// MARK: - Preview

#Preview {
    MacTournamentsView()
        .frame(width: 800, height: 700)
}
