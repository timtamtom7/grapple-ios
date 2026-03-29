import SwiftUI

/// Displays the weekly debate challenge ("Challenge of the Week").
struct MacChallengeView: View {
    @StateObject private var viewModel = ChallengeViewModel()
    @State private var submittedArgument: String = ""
    @State private var showSubmissionConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MacTheme.sectionSpacing) {
                headerSection

                if viewModel.isLoading {
                    loadingSection
                } else {
                    challengeCardSection
                    submitSection
                    leaderboardSection
                    pastChallengesSection
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(MacTheme.background)
        .task {
            await viewModel.loadChallenge()
        }
        .alert("Argument Submitted!", isPresented: $showSubmissionConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your argument has been submitted. Check back later to see if you've been featured in the top 3!")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Challenge of the Week")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(MacTheme.primaryText)

            Text("A new debate challenge drops every Monday. Submit your best argument — top 3 get featured.")
                .font(.system(size: 15))
                .foregroundColor(MacTheme.secondaryText)
        }
    }

    // MARK: - Challenge Card

    private var challengeCardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                sectionLabel("This Week's Challenge")
                Spacer()
                countdownBadge
            }

            challengeCard
        }
    }

    private var challengeCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Topic
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24))
                    .foregroundColor(MacTheme.challenge)

                Text(viewModel.currentChallenge.topic)
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(MacTheme.primaryText)
                    .lineSpacing(4)
            }

            Divider()
                .background(MacTheme.divider)

            // Details
            HStack(spacing: 24) {
                detailItem(icon: "person.2", value: "\(viewModel.currentChallenge.submissionCount)", label: "Submitted")
                detailItem(icon: "arrow.up", value: "\(viewModel.currentChallenge.topVotes)", label: "Top Votes")
                detailItem(icon: "clock", value: viewModel.currentChallenge.daysRemaining, label: "Days Left")
            }

            // Description
            Text(viewModel.currentChallenge.description_)
                .font(.system(size: 14))
                .foregroundColor(MacTheme.secondaryText)
                .lineSpacing(3)

            // Tags
            HStack(spacing: 8) {
                ForEach(viewModel.currentChallenge.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(MacTheme.rebuttal)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MacTheme.rebuttal.opacity(0.15))
                        .cornerRadius(4)
                }
            }
        }
        .padding(20)
        .background(MacTheme.surface)
        .cornerRadius(MacTheme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: MacTheme.cornerRadius)
                .stroke(MacTheme.challenge.opacity(0.3), lineWidth: 1)
        )
    }

    private var countdownBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12))
            Text("Active")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(MacTheme.challenge)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(MacTheme.challenge.opacity(0.15))
        .cornerRadius(6)
    }

    // MARK: - Submit Section

    private var submitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Submit Your Argument")

            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $submittedArgument)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundColor(MacTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(MacTheme.surface)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MacTheme.divider, lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if submittedArgument.isEmpty {
                            Text("Your best argument...")
                                .font(.system(size: 15, design: .monospaced))
                                .foregroundColor(MacTheme.secondaryText.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                        }
                    }

                HStack {
                    Text("\(submittedArgument.count) / 500 characters")
                        .font(.system(size: 12))
                        .foregroundColor(submittedArgument.count > 500 ? MacTheme.challenge : MacTheme.secondaryText)

                    Spacer()

                    Button(action: submitArgument) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 13))
                            Text("Submit")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            submittedArgument.isEmpty || submittedArgument.count > 500
                            ? MacTheme.secondaryText
                            : MacTheme.rebuttal
                        )
                        .cornerRadius(8)
                    }
                    .disabled(submittedArgument.isEmpty || submittedArgument.count > 500)
                }
            }

            // Rules
            VStack(alignment: .leading, spacing: 6) {
                Text("Rules:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)

                ForEach(challengeRules, id: \.self) { rule in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(MacTheme.success)
                        Text(rule)
                            .font(.system(size: 13))
                            .foregroundColor(MacTheme.secondaryText)
                    }
                }
            }
            .padding(14)
            .background(MacTheme.surface)
            .cornerRadius(10)
        }
    }

    // MARK: - Leaderboard

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Current Leaderboard")

            ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                LeaderboardRow(rank: index + 1, entry: entry)
            }
        }
    }

    // MARK: - Past Challenges

    private var pastChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("Past Challenges")

            ForEach(viewModel.pastChallenges) { challenge in
                PastChallengeRow(challenge: challenge)
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
            Text("Loading challenge...")
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

    private func detailItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(MacTheme.secondaryText)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(MacTheme.secondaryText)
            }
        }
    }

    private var challengeRules: [String] {
        [
            "Be rigorous — support claims with reasoning, not just assertions",
            "Address the strongest counterarguments",
            "Stay under 500 characters",
            "One submission per person per week"
        ]
    }

    private func submitArgument() {
        Task {
            await viewModel.submitArgument(submittedArgument)
            submittedArgument = ""
            showSubmissionConfirmation = true
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let rank: Int
    let entry: ChallengeEntry

    var body: some View {
        HStack(spacing: 14) {
            // Rank
            Text(rankText)
                .font(.system(size: 16, weight: rank <= 3 ? .bold : .medium))
                .foregroundColor(rankColor)
                .frame(width: 28)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)

                Text(entry.argument)
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            // Votes
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 11))
                    Text("\(entry.votes)")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(MacTheme.success)

                if rank <= 3 {
                    Text("Featured")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(MacTheme.success)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MacTheme.success.opacity(0.15))
                        .cornerRadius(3)
                }
            }
        }
        .padding(14)
        .background(rank <= 3 ? MacTheme.elevated : MacTheme.surface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(rank <= 3 ? MacTheme.success.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }

    private var rankText: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return MacTheme.secondaryText
        }
    }
}

// MARK: - Past Challenge Row

struct PastChallengeRow: View {
    let challenge: PastChallenge

    var body: some View {
        HStack(spacing: 14) {
            // Week indicator
            VStack(spacing: 2) {
                Text(challenge.weekLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MacTheme.primaryText)
                Text(challenge.yearLabel)
                    .font(.system(size: 10))
                    .foregroundColor(MacTheme.secondaryText)
            }
            .frame(width: 44, height: 44)
            .background(MacTheme.elevated)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 3) {
                Text(challenge.topic)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                    .lineLimit(1)

                Text("\(challenge.participantCount) participants")
                    .font(.system(size: 12))
                    .foregroundColor(MacTheme.secondaryText)
            }

            Spacer()

            Text("Winner: \(challenge.winnerName)")
                .font(.system(size: 12))
                .foregroundColor(MacTheme.secondaryText)
        }
        .padding(14)
        .background(MacTheme.surface)
        .cornerRadius(10)
    }
}

// MARK: - ViewModel

@MainActor
final class ChallengeViewModel: ObservableObject {
    @Published var currentChallenge: WeeklyChallenge = WeeklyChallenge.placeholder
    @Published var leaderboard: [ChallengeEntry] = []
    @Published var pastChallenges: [PastChallenge] = []
    @Published var isLoading = false

    func loadChallenge() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 500_000_000)

        currentChallenge = WeeklyChallenge.current
        leaderboard = ChallengeEntry.samples
        pastChallenges = PastChallenge.samples
    }

    func submitArgument(_ text: String) async {
        try? await Task.sleep(nanoseconds: 400_000_000)
        // In a real app, this would submit to a backend
    }
}

// MARK: - Models

struct WeeklyChallenge {
    let topic: String
    let description_: String
    let tags: [String]
    let submissionCount: Int
    let topVotes: Int
    let daysRemaining: String

    static let placeholder = WeeklyChallenge(
        topic: "Loading...",
        description_: "",
        tags: [],
        submissionCount: 0,
        topVotes: 0,
        daysRemaining: "—"
    )

    static let current = WeeklyChallenge(
        topic: "Is AI consciousness meaningful?",
        description_: "This week: Can an AI system ever truly be conscious, or is it merely simulating awareness? Does the distinction matter? Submit your sharpest argument.",
        tags: ["AI", "Philosophy of Mind", "Consciousness"],
        submissionCount: 247,
        topVotes: 89,
        daysRemaining: "4"
    )
}

struct ChallengeEntry: Identifiable {
    let id = UUID()
    let displayName: String
    let argument: String
    let votes: Int

    static let samples: [ChallengeEntry] = [
        ChallengeEntry(
            displayName: "Sarah C.",
            argument: "Consciousness requires subjective experience, which cannot be reduced to computational processes regardless of their complexity.",
            votes: 89
        ),
        ChallengeEntry(
            displayName: "Marcus W.",
            argument: "If an AI behaves indistinguishably from a conscious being in all contexts, the functional distinction becomes irrelevant.",
            votes: 76
        ),
        ChallengeEntry(
            displayName: "Aisha P.",
            argument: "Meaningful consciousness requires causal agency in the world, not just information processing — AI lacks the former.",
            votes: 54
        ),
        ChallengeEntry(
            displayName: "James O.",
            argument: "The hard problem of consciousness remains unsolved for humans too, making the AI question premature.",
            votes: 41
        ),
        ChallengeEntry(
            displayName: "Yuki T.",
            argument: "Consciousness may be an emergent property — sufficiently complex AI could cross that threshold unexpectedly.",
            votes: 33
        )
    ]
}

struct PastChallenge: Identifiable {
    let id = UUID()
    let weekLabel: String
    let yearLabel: String
    let topic: String
    let participantCount: Int
    let winnerName: String

    static let samples: [PastChallenge] = [
        PastChallenge(weekLabel: "WK 12", yearLabel: "2026", topic: "Free will is an illusion", participantCount: 312, winnerName: "Marcus W."),
        PastChallenge(weekLabel: "WK 11", yearLabel: "2026", topic: "Universal basic income is viable", participantCount: 289, winnerName: "Aisha P."),
        PastChallenge(weekLabel: "WK 10", yearLabel: "2026", topic: "Nuclear power is essential", participantCount: 341, winnerName: "James O.")
    ]
}

// MARK: - Preview

#Preview {
    MacChallengeView()
        .frame(width: 800, height: 900)
}
