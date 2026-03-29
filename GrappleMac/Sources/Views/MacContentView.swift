import SwiftUI

struct MacContentView: View {
    @State private var selectedTab: MacTab = .debate
    @State private var selectedSession: GrappleSession?

    var body: some View {
        NavigationSplitView {
            MacSidebarView(selectedTab: $selectedTab, selectedSession: $selectedSession)
                .frame(minWidth: 240, idealWidth: 260)
        } detail: {
            switch selectedTab {
            case .debate:
                if let session = selectedSession {
                    MacSessionDetailView(session: session)
                } else {
                    MacDebateView()
                }
            case .history:
                MacArgumentHistoryView(selectedSession: $selectedSession)
            case .settings:
                MacSettingsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 600)
    }
}

enum MacTab: String, CaseIterable {
    case debate = "New"
    case history = "History"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .debate: return "square.and.pencil"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gear"
        }
    }
}

struct MacSidebarView: View {
    @Binding var selectedTab: MacTab
    @Binding var selectedSession: GrappleSession?
    @StateObject private var historyVM = MacHistoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Grapple")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            Divider()
                .background(MacTheme.divider)

            // Tab buttons
            VStack(spacing: 4) {
                ForEach(MacTab.allCases, id: \.self) { tab in
                    MacSidebarButton(
                        title: tab.rawValue,
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                        if tab != .history {
                            selectedSession = nil
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider()
                .background(MacTheme.divider)
                .padding(.top, 16)

            // Recent sessions
            if !historyVM.sessions.isEmpty && selectedTab == .debate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RECENT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(MacTheme.secondaryText)
                        .padding(.horizontal, 8)

                    ForEach(historyVM.sessions.prefix(5)) { session in
                        Button {
                            selectedSession = session
                            selectedTab = .debate
                        } label: {
                            HStack {
                                Text(session.topic)
                                    .font(.system(size: 13))
                                    .foregroundColor(selectedSession?.id == session.id ? MacTheme.primaryText : MacTheme.secondaryText)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(selectedSession?.id == session.id ? MacTheme.elevated : Color.clear)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 8)
            }

            Spacer()

            // Menu bar extra hint
            HStack {
                Image(systemName: "menubar.rectangle")
                    .font(.system(size: 12))
                Text("Menu bar extra available")
                    .font(.system(size: 11))
                Spacer()
            }
            .foregroundColor(MacTheme.secondaryText)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(MacTheme.surface)
    }
}

struct MacSidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                Spacer()
            }
            .foregroundColor(isSelected ? .white : MacTheme.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? MacTheme.elevated : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Switch to \(title) view")
    }
}

#Preview {
    MacContentView()
}
