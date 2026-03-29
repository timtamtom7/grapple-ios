import SwiftUI

struct MacArgumentHistoryView: View {
    @Binding var selectedSession: GrappleSession?
    @StateObject private var viewModel = MacHistoryViewModel()
    @State private var searchText: String = ""

    var filteredSessions: [GrappleSession] {
        if searchText.isEmpty {
            return viewModel.sessions
        }
        return viewModel.sessions.filter {
            $0.topic.localizedCaseInsensitiveContains(searchText) ||
            $0.originalInput.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("History")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(MacTheme.primaryText)
                Spacer()
                Text("\(viewModel.sessions.count) sessions")
                    .font(.system(size: 13))
                    .foregroundColor(MacTheme.secondaryText)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            Divider()
                .background(MacTheme.divider)

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(MacTheme.secondaryText)
                TextField("Search sessions...", text: $searchText)
                    .foregroundColor(MacTheme.primaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(MacTheme.surface)
            .cornerRadius(8)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            Divider()
                .background(MacTheme.divider)

            // Session list
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filteredSessions) { session in
                        MacSessionRow(session: session, isSelected: selectedSession?.id == session.id)
                            .onTapGesture {
                                selectedSession = session
                            }
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MacTheme.background)
        }
        .background(MacTheme.background)
    }
}

struct MacSessionRow: View {
    let session: GrappleSession
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.topic)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(MacTheme.primaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(MacTheme.secondaryText)
                    Text("•")
                        .foregroundColor(MacTheme.divider)
                    Text("\(session.counterArguments.count) challenges")
                        .font(.system(size: 12))
                        .foregroundColor(MacTheme.secondaryText)
                }
            }

            Spacer()

            OutcomeBadge(outcome: session.outcome)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(MacTheme.divider)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? MacTheme.elevated : Color.clear)
        .cornerRadius(8)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.createdAt)
    }
}

struct MacSessionDetailView: View {
    let session: GrappleSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(session.topic)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(MacTheme.primaryText)
                        Spacer()
                        OutcomeBadge(outcome: session.outcome)
                    }
                    Text("Debate Mode: \(session.debateMode.rawValue)")
                        .font(.system(size: 12))
                        .foregroundColor(MacTheme.secondaryText)
                }

                // Original input
                VStack(alignment: .leading, spacing: 6) {
                    Text("ORIGINAL CLAIM")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MacTheme.secondaryText)
                    Text(session.originalInput)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(MacTheme.primaryText)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(MacTheme.surface)
                        .cornerRadius(8)
                }

                // Counter-arguments
                VStack(alignment: .leading, spacing: 8) {
                    Text("CHALLENGES (\(session.counterArguments.count))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MacTheme.secondaryText)

                    ForEach(Array(session.counterArguments.enumerated()), id: \.element.id) { index, argument in
                        MacArgumentCard(argument: argument, index: index + 1)
                    }
                }

                // Synthesis
                if let synthesis = session.synthesis {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SYNTHESIS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(MacTheme.secondaryText)
                        MacSynthesisCard(synthesis: synthesis)
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MacTheme.background)
    }
}

#Preview {
    MacArgumentHistoryView(selectedSession: .constant(nil))
}
